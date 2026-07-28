import 'package:el_race/core/performance/models/performance_evaluation.dart';
import 'package:el_race/core/performance/network/performance_api_client.dart';
import 'package:el_race/core/performance/network/performance_client_factory.dart';
import 'package:el_race/core/performance/performance_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PerformancePlanningState {
  const PerformancePlanningState({
    this.info,
    this.isLoading = false,
    this.error,
  });

  final PerformancePlanningInfo? info;
  final bool isLoading;
  final String? error;

  static const initial = PerformancePlanningState();
}

class PerformancePlanningCubit extends Cubit<PerformancePlanningState> {
  PerformancePlanningCubit({PerformanceApiClient? client})
      : _client = client ?? createPerformanceApiClient(),
        super(PerformancePlanningState.initial);

  final PerformanceApiClient _client;
  bool _hasLoaded = false;

  Future<void> load({bool force = false}) async {
    if (!force && (_hasLoaded || state.isLoading)) return;
    _hasLoaded = true;
    emit(PerformancePlanningState(info: state.info, isLoading: true));

    try {
      final env = await _client.fetchPlanning();
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not load planning info');
      }
      emit(PerformancePlanningState(info: planningFromJson(env.data!)));
    } catch (e) {
      emit(PerformancePlanningState(info: state.info, error: e.toString()));
    }
  }
}
