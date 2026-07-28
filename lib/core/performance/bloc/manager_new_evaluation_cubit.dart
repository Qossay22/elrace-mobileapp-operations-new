import 'package:el_race/core/performance/models/performance_employee_option.dart';
import 'package:el_race/core/performance/models/performance_evaluation.dart';
import 'package:el_race/core/performance/network/performance_api_client.dart';
import 'package:el_race/core/performance/network/performance_client_factory.dart';
import 'package:el_race/core/performance/performance_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagerNewEvaluationState {
  const ManagerNewEvaluationState({
    required this.employees,
    required this.year,
    this.selectedEmployee,
    this.evaluationId,
    this.detail,
    this.isLoadingEmployees = false,
    this.isLoadingDetail = false,
    this.isBusy = false,
    this.error,
  });

  final List<PerformanceEmployeeOption> employees;
  final int year;
  final PerformanceEmployeeOption? selectedEmployee;
  final String? evaluationId;
  final PerformanceEvaluationDetail? detail;
  final bool isLoadingEmployees;
  final bool isLoadingDetail;
  final bool isBusy;
  final String? error;

  static ManagerNewEvaluationState initial() => ManagerNewEvaluationState(
        employees: const <PerformanceEmployeeOption>[],
        year: DateTime.now().year,
      );

  ManagerNewEvaluationState copyWith({
    List<PerformanceEmployeeOption>? employees,
    int? year,
    PerformanceEmployeeOption? selectedEmployee,
    String? evaluationId,
    PerformanceEvaluationDetail? detail,
    bool? isLoadingEmployees,
    bool? isLoadingDetail,
    bool? isBusy,
    String? error,
    bool clearError = false,
  }) {
    return ManagerNewEvaluationState(
      employees: employees ?? this.employees,
      year: year ?? this.year,
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      evaluationId: evaluationId ?? this.evaluationId,
      detail: detail ?? this.detail,
      isLoadingEmployees: isLoadingEmployees ?? this.isLoadingEmployees,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ManagerNewEvaluationCubit extends Cubit<ManagerNewEvaluationState> {
  ManagerNewEvaluationCubit({PerformanceApiClient? client})
      : _client = client ?? createPerformanceApiClient(),
        super(ManagerNewEvaluationState.initial());

  final PerformanceApiClient _client;
  bool _hasLoadedEmployees = false;

  Future<void> loadEmployees({bool force = false}) async {
    if (!force && (_hasLoadedEmployees || state.isLoadingEmployees)) return;
    _hasLoadedEmployees = true;
    emit(state.copyWith(isLoadingEmployees: true, clearError: true));

    try {
      final env = await _client.fetchEmployees();
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not load employees');
      }
      final employees = env.data!.map(employeeOptionFromJson).toList();
      emit(
        state.copyWith(
          employees: employees,
          selectedEmployee: state.selectedEmployee ??
              (employees.isNotEmpty ? employees.first : null),
          isLoadingEmployees: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingEmployees: false,
          error: e.toString(),
        ),
      );
    }
  }

  void selectEmployee(PerformanceEmployeeOption? employee) {
    if (state.evaluationId != null) return;
    emit(state.copyWith(selectedEmployee: employee, clearError: true));
  }

  void setYear(int year) {
    if (state.evaluationId != null) return;
    emit(state.copyWith(year: year, clearError: true));
  }

  Future<bool> prepareDraft() async {
    final employee = state.selectedEmployee;
    if (employee == null) {
      emit(state.copyWith(error: 'Select an employee first.'));
      return false;
    }

    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final env = await _client.createEvaluation(
        employeeId: int.parse(employee.id),
        year: state.year,
      );
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not create evaluation');
      }
      final id = env.data!['id']?.toString();
      if (id == null || id.isEmpty) {
        throw Exception('Invalid response from server');
      }

      emit(
        state.copyWith(
          evaluationId: id,
          isBusy: false,
          isLoadingDetail: true,
          clearError: true,
        ),
      );
      await _loadDetail(id);
      return true;
    } catch (e) {
      emit(state.copyWith(isBusy: false, error: e.toString()));
      return false;
    }
  }

  Future<String?> save(List<int> scores) async {
    final id = state.evaluationId;
    final detail = state.detail;
    if (id == null || detail == null) {
      emit(state.copyWith(error: 'Prepare the draft first.'));
      return null;
    }

    final rows = detail.competencies;
    if (scores.length != rows.length) {
      emit(state.copyWith(error: 'Evaluation scores are incomplete.'));
      return null;
    }

    for (var i = 0; i < rows.length; i++) {
      final max = rows[i].maxScore;
      if (scores[i] < 0 || scores[i] > max) {
        emit(state.copyWith(
            error: 'Row ${i + 1}: score must be between 0 and $max.'));
        return null;
      }
    }

    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final lines = [
        for (var i = 0; i < rows.length; i++)
          {
            'line_id': int.tryParse(rows[i].lineId) ?? rows[i].lineId,
            'user_score': scores[i],
          },
      ];
      final env = await _client.saveEvaluation(id: id, lines: lines);
      if (!env.success) {
        throw Exception(env.error ?? 'Save failed');
      }
      emit(state.copyWith(isBusy: false, clearError: true));
      return id;
    } catch (e) {
      emit(state.copyWith(isBusy: false, error: e.toString()));
      return null;
    }
  }

  Future<void> _loadDetail(String id) async {
    try {
      final env = await _client.fetchEvaluationDetail(id);
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not load evaluation');
      }
      emit(
        state.copyWith(
          detail: detailFromJson(env.data!),
          isLoadingDetail: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingDetail: false,
          error: e.toString(),
        ),
      );
    }
  }
}
