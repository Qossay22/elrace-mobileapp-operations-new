import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:el_race/data/models/global_search_item.dart';
import 'package:el_race/data/services/global_search_api_service.dart';
import 'package:el_race/data/services/global_search_history_service.dart';
import 'package:flutter/foundation.dart';

import 'global_search_event.dart';
import 'global_search_state.dart';

class GlobalSearchBloc extends Bloc<GlobalSearchEvent, GlobalSearchState> {
  GlobalSearchBloc({
    GlobalSearchApiService? apiService,
  })  : _apiService = apiService ?? GlobalSearchApiService(),
        super(const GlobalSearchState()) {
    on<GlobalSearchQueryChanged>(_onQueryChanged);
    on<GlobalSearchImmediateRequested>(_onImmediateRequested);
    on<GlobalSearchRetryRequested>(_onRetryRequested);
    on<GlobalSearchCleared>(_onCleared);
    on<GlobalSearchCategoryLoadMoreRequested>(_onLoadMoreRequested);
  }

  final GlobalSearchApiService _apiService;
  Timer? _debounceTimer;
  int _searchGeneration = 0;
  CancelToken? _cancelToken;
  static const Duration _debounceDuration = Duration(milliseconds: 400);

  void _onQueryChanged(
    GlobalSearchQueryChanged event,
    Emitter<GlobalSearchState> emit,
  ) {
    _debounceTimer?.cancel();
    final keyword = event.keyword.trim();

    if (keyword.isEmpty || keyword.length < 2) {
      _clear(emit);
      return;
    }

    emit(state.copyWith(
      status: GlobalSearchStatus.loading,
      currentKeyword: event.keyword,
      clearErrorMessage: true,
    ));

    _debounceTimer = Timer(_debounceDuration, () {
      add(GlobalSearchImmediateRequested(
        keyword: event.keyword,
        limitPerCategory: event.limitPerCategory,
      ));
    });
  }

  Future<void> _onImmediateRequested(
    GlobalSearchImmediateRequested event,
    Emitter<GlobalSearchState> emit,
  ) async {
    _debounceTimer?.cancel();
    final keyword = event.keyword.trim();

    if (keyword.isEmpty) {
      _clear(emit);
      return;
    }

    await _performSearch(
      emit,
      keyword: event.keyword,
      limitPerCategory: event.limitPerCategory,
    );
  }

  Future<void> _onRetryRequested(
    GlobalSearchRetryRequested event,
    Emitter<GlobalSearchState> emit,
  ) async {
    if (state.currentKeyword.isEmpty) return;
    await _performSearch(
      emit,
      keyword: state.currentKeyword,
      limitPerCategory: state.limitPerCategory,
    );
  }

  void _onCleared(
    GlobalSearchCleared event,
    Emitter<GlobalSearchState> emit,
  ) {
    _clear(emit);
  }

  Future<void> _performSearch(
    Emitter<GlobalSearchState> emit, {
    required String keyword,
    int limitPerCategory = 5,
  }) async {
    final generation = ++_searchGeneration;
    _cancelToken?.cancel('superseded');
    _cancelToken = _apiService.createCancelToken();

    try {
      emit(state.copyWith(
        status: GlobalSearchStatus.loading,
        currentKeyword: keyword,
        clearErrorMessage: true,
      ));

      final page = await _apiService.globalSearchAll(
        keyword: keyword,
        limitPerCategory: limitPerCategory,
        cancelToken: _cancelToken,
      );

      if (generation != _searchGeneration) return;

      emit(state.copyWith(
        status: page.items.isEmpty
            ? GlobalSearchStatus.empty
            : GlobalSearchStatus.loaded,
        results: page.items,
        countsByCategory: page.countsByCategory,
        limitPerCategory: page.limitPerCategory,
        clearErrorMessage: true,
        clearLoadingMoreCategory: true,
      ));

      if (page.items.isNotEmpty) {
        await GlobalSearchHistoryService.addQuery(keyword);
      }
    } on GlobalSearchApiException catch (error) {
      if (generation != _searchGeneration) return;
      if (error.message == 'Search cancelled') return;
      emit(state.copyWith(
        status: GlobalSearchStatus.error,
        results: const [],
        errorMessage: error.message,
      ));
    } catch (error) {
      if (generation != _searchGeneration) return;
      emit(state.copyWith(
        status: GlobalSearchStatus.error,
        results: const [],
        errorMessage: 'An unexpected error occurred',
      ));
      if (kDebugMode) {
        debugPrint('GlobalSearchBloc error: $error');
      }
    }
  }

  Future<List<GlobalSearchItem>> fetchCategoryList({
    required String category,
    required String keyword,
  }) async {
    final page = await _apiService.globalSearchCategory(
      category: category,
      keyword: keyword,
      limit: 50,
      cancelToken: _cancelToken,
    );
    return page.items;
  }

  Future<void> _onLoadMoreRequested(
    GlobalSearchCategoryLoadMoreRequested event,
    Emitter<GlobalSearchState> emit,
  ) async {
    final category = event.category;
    if (state.currentKeyword.trim().isEmpty) return;
    if (state.loadingMoreCategory != null) return;
    if (!state.hasMoreInCategory(category)) return;

    emit(state.copyWith(loadingMoreCategory: category));

    try {
      final total = state.countsByCategory[category];
      final limit = total != null && total > 0 ? total.clamp(1, 50) : 50;

      final page = await _apiService.globalSearchCategory(
        category: category,
        keyword: state.currentKeyword,
        limit: limit,
        cancelToken: _cancelToken,
      );

      final results = [
        ...state.results.where((e) => e.category != category),
        ...page.items,
      ];

      final countsByCategory = {...state.countsByCategory};
      if (page.countsByCategory.isNotEmpty) {
        countsByCategory.addAll(page.countsByCategory);
      } else if (total != null) {
        countsByCategory[category] = page.items.length;
      }

      emit(state.copyWith(
        status: results.isEmpty
            ? GlobalSearchStatus.empty
            : GlobalSearchStatus.loaded,
        results: results,
        countsByCategory: countsByCategory,
        clearLoadingMoreCategory: true,
      ));
    } on GlobalSearchApiException catch (error) {
      if (error.message == 'Search cancelled') return;
      emit(state.copyWith(
        status: GlobalSearchStatus.error,
        errorMessage: error.message,
        clearLoadingMoreCategory: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: GlobalSearchStatus.error,
        errorMessage: 'An unexpected error occurred',
        clearLoadingMoreCategory: true,
      ));
    }
  }

  void _clear(Emitter<GlobalSearchState> emit) {
    _debounceTimer?.cancel();
    _searchGeneration++;
    _cancelToken?.cancel('cleared');
    _cancelToken = null;
    emit(const GlobalSearchState());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _apiService.cancelRequests();
    _cancelToken?.cancel('disposed');
    return super.close();
  }
}
