import 'package:el_race/core/performance/models/performance_evaluation.dart';
import 'package:el_race/core/performance/network/performance_api_client.dart';
import 'package:el_race/core/performance/network/performance_client_factory.dart';
import 'package:el_race/core/performance/performance_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeePerformanceState {
  const EmployeePerformanceState({
    required this.year,
    this.detail,
    this.isLoading = false,
    this.error,
  });

  final int year;
  final PerformanceEvaluationDetail? detail;
  final bool isLoading;
  final String? error;

  static EmployeePerformanceState initial() =>
      EmployeePerformanceState(year: DateTime.now().year);
}

class EmployeePerformanceCubit extends Cubit<EmployeePerformanceState> {
  EmployeePerformanceCubit({PerformanceApiClient? client})
      : _client = client ?? createPerformanceApiClient(),
        super(EmployeePerformanceState.initial());

  final PerformanceApiClient _client;
  int? _loadedYear;

  Future<void> load({bool force = false}) async {
    if (!force && _loadedYear == state.year) return;
    _loadedYear = state.year;
    emit(EmployeePerformanceState(year: state.year, isLoading: true));

    try {
      final env = await _client.fetchMyEvaluation(state.year);
      if (!env.success) {
        throw Exception(env.error ?? 'Could not load evaluation');
      }
      emit(
        EmployeePerformanceState(
          year: state.year,
          detail: env.data == null ? null : detailFromJson(env.data!),
        ),
      );
    } catch (e) {
      emit(EmployeePerformanceState(year: state.year, error: e.toString()));
    }
  }

  Future<void> setYear(int year) async {
    if (year == state.year) return;
    _loadedYear = null;
    emit(EmployeePerformanceState(year: year));
    await load();
  }
}
