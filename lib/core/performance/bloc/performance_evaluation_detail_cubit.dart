import 'package:el_race/core/performance/models/performance_evaluation.dart';
import 'package:el_race/core/performance/network/performance_api_client.dart';
import 'package:el_race/core/performance/network/performance_client_factory.dart';
import 'package:el_race/core/performance/performance_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PerformanceEvaluationDetailState {
  const PerformanceEvaluationDetailState({
    this.detail,
    this.loadedId,
    this.isLoading = false,
    this.error,
  });

  final PerformanceEvaluationDetail? detail;
  final String? loadedId;
  final bool isLoading;
  final String? error;

  static const initial = PerformanceEvaluationDetailState();
}

class PerformanceEvaluationDetailCubit
    extends Cubit<PerformanceEvaluationDetailState> {
  PerformanceEvaluationDetailCubit({PerformanceApiClient? client})
      : _client = client ?? createPerformanceApiClient(),
        super(PerformanceEvaluationDetailState.initial);

  final PerformanceApiClient _client;

  Future<void> load(String id, {bool force = false}) async {
    final normalizedId = id.trim();
    if (!force &&
        state.loadedId == normalizedId &&
        (state.isLoading || state.detail != null || state.error != null)) {
      return;
    }

    emit(
      PerformanceEvaluationDetailState(
        loadedId: normalizedId,
        detail: state.loadedId == normalizedId ? state.detail : null,
        isLoading: true,
      ),
    );

    try {
      final env = await _client.fetchEvaluationDetail(normalizedId);
      if (!env.success) {
        throw Exception(env.error ?? 'Could not load evaluation');
      }
      emit(
        PerformanceEvaluationDetailState(
          loadedId: normalizedId,
          detail: env.data == null ? null : detailFromJson(env.data!),
        ),
      );
    } catch (e) {
      emit(
        PerformanceEvaluationDetailState(
          loadedId: normalizedId,
          error: e.toString(),
        ),
      );
    }
  }
}
