import 'package:el_race/core/performance/models/performance_evaluation.dart';
import 'package:el_race/core/performance/network/performance_api_client.dart';
import 'package:el_race/core/performance/network/performance_client_factory.dart';
import 'package:el_race/core/performance/performance_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PerformanceEvaluationListState {
  const PerformanceEvaluationListState({
    required this.items,
    this.isLoading = false,
    this.error,
  });

  final List<PerformanceEvaluationSummary> items;
  final bool isLoading;
  final String? error;

  static const initial =
      PerformanceEvaluationListState(items: <PerformanceEvaluationSummary>[]);
}

class PerformanceEvaluationListCubit
    extends Cubit<PerformanceEvaluationListState> {
  PerformanceEvaluationListCubit({PerformanceApiClient? client})
      : _client = client ?? createPerformanceApiClient(),
        super(PerformanceEvaluationListState.initial);

  final PerformanceApiClient _client;
  bool _hasLoaded = false;

  Future<void> load({bool force = false}) async {
    if (!force && (_hasLoaded || state.isLoading)) return;
    _hasLoaded = true;
    await refresh();
  }

  Future<void> refresh() async {
    emit(
      PerformanceEvaluationListState(
        items: state.items,
        isLoading: true,
      ),
    );

    try {
      final env = await _client.fetchEvaluations();
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not load evaluations');
      }
      emit(
        PerformanceEvaluationListState(
          items: env.data!.map(summaryFromJson).toList(),
        ),
      );
    } catch (e) {
      emit(
        PerformanceEvaluationListState(
          items: state.items,
          error: e.toString(),
        ),
      );
    }
  }
}
