import 'package:el_race/core/payslip/models/payslip_models.dart';
import 'package:el_race/core/payslip/network/payslip_api_client.dart';
import 'package:el_race/core/payslip/network/payslip_client_factory.dart';
import 'package:el_race/core/payslip/payslip_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PayslipListState {
  const PayslipListState({
    required this.items,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<PayslipSummary> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  static const initial = PayslipListState(items: <PayslipSummary>[]);
}

class PayslipListCubit extends Cubit<PayslipListState> {
  PayslipListCubit({PayslipApiClient? client})
      : _client = client ?? createPayslipApiClient(),
        super(PayslipListState.initial);

  final PayslipApiClient _client;
  static const _pageSize = 30;

  int _page = 1;
  int? _filterYear;
  int? _filterMonth;
  String? _keyword;
  bool _hasLoaded = false;

  Future<void> load({bool force = false}) async {
    if (!force && _hasLoaded) return;
    _hasLoaded = true;
    await refresh();
  }

  Future<void> setFilters({int? year, int? month, String? keyword}) async {
    _filterYear = year;
    _filterMonth = month;
    _keyword = keyword;
    await refresh();
  }

  Future<void> refresh() async {
    _page = 1;
    emit(
      PayslipListState(
        items: state.items,
        isLoading: true,
        hasMore: state.hasMore,
      ),
    );
    try {
      final batch = await _fetch(page: 1);
      emit(
        PayslipListState(
          items: batch,
          hasMore: batch.length == _pageSize,
        ),
      );
    } catch (e) {
      emit(
        PayslipListState(
          items: state.items,
          hasMore: state.hasMore,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final next = _page + 1;
    emit(
      PayslipListState(
        items: state.items,
        isLoadingMore: true,
        hasMore: state.hasMore,
      ),
    );
    try {
      final batch = await _fetch(page: next);
      final ids = state.items.map((e) => e.id).toSet();
      final merged = [
        ...state.items,
        ...batch.where((e) => !ids.contains(e.id)),
      ];
      _page = next;
      emit(
        PayslipListState(
          items: merged,
          hasMore: batch.length == _pageSize,
        ),
      );
    } catch (e) {
      emit(
        PayslipListState(
          items: state.items,
          hasMore: state.hasMore,
          error: e.toString(),
        ),
      );
    }
  }

  Future<List<PayslipSummary>> _fetch({required int page}) async {
    final env = await _client.fetchPayslips(
      page: page,
      limit: _pageSize,
      year: _filterYear,
      month: _filterMonth,
      keyword: _keyword,
    );
    if (!env.success || env.data == null) {
      throw Exception(env.error ?? 'Could not load payslips');
    }
    return env.data!.map(summaryFromJson).toList();
  }
}
