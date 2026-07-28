import 'package:bloc/bloc.dart';
import 'package:el_race/data/services/announcements_api_service.dart';

import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc({
    AnnouncementsApiService? apiService,
  })  : _apiService = apiService ?? AnnouncementsApiService(),
        super(const NewsState()) {
    on<NewsRequested>(_onRequested);
    on<NewsRefreshRequested>(_onRefreshRequested);
  }

  final AnnouncementsApiService _apiService;

  Future<void> _onRequested(
    NewsRequested event,
    Emitter<NewsState> emit,
  ) async {
    await _fetchAnnouncements(event.category, emit);
  }

  Future<void> _onRefreshRequested(
    NewsRefreshRequested event,
    Emitter<NewsState> emit,
  ) async {
    await _fetchAnnouncements(state.currentCategory, emit);
  }

  Future<void> _fetchAnnouncements(
    AnnouncementCategory category,
    Emitter<NewsState> emit,
  ) async {
    emit(state.copyWith(
      status: NewsStatus.loading,
      currentCategory: category,
      errorMessage: null,
    ));

    try {
      final results = await _apiService.fetchAnnouncements(category: category);
      emit(state.copyWith(
        status: results.isEmpty ? NewsStatus.empty : NewsStatus.loaded,
        announcements: results,
        errorMessage: null,
      ));
    } on AnnouncementApiException catch (error) {
      emit(state.copyWith(
        status: NewsStatus.error,
        announcements: const [],
        errorMessage: error.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: NewsStatus.error,
        announcements: const [],
        errorMessage: 'An unexpected error occurred: $error',
      ));
    }
  }
}
