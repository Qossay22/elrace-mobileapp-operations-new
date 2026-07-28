import 'package:el_race/core/payslip/models/payslip_models.dart';
import 'package:el_race/core/payslip/network/payslip_api_client.dart';
import 'package:el_race/core/payslip/network/payslip_client_factory.dart';
import 'package:el_race/core/payslip/payslip_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeePayslipState {
  const EmployeePayslipState({
    required this.monthPayslips,
    required this.recentPayslips,
    required this.isLoading,
    this.error,
  });

  final List<PayslipSummary> monthPayslips;
  final List<PayslipSummary> recentPayslips;
  final bool isLoading;
  final String? error;

  static const initial = EmployeePayslipState(
    monthPayslips: <PayslipSummary>[],
    recentPayslips: <PayslipSummary>[],
    isLoading: false,
  );
}

class EmployeePayslipCubit extends Cubit<EmployeePayslipState> {
  EmployeePayslipCubit({PayslipApiClient? client})
      : _client = client ?? createPayslipApiClient(),
        super(EmployeePayslipState.initial);

  final PayslipApiClient _client;
  DateTime? _lastLoadedMonth;

  Future<void> load(DateTime filterMonth, {bool force = false}) async {
    final month = DateTime(filterMonth.year, filterMonth.month, 1);
    if (!force && _lastLoadedMonth == month) return;
    _lastLoadedMonth = month;

    emit(
      EmployeePayslipState(
        monthPayslips: state.monthPayslips,
        recentPayslips: state.recentPayslips,
        isLoading: true,
      ),
    );

    try {
      final monthEnv = await _client.fetchPayslips(
        page: 1,
        limit: 5,
        year: month.year,
        month: month.month,
      );
      if (!monthEnv.success || monthEnv.data == null) {
        throw Exception(monthEnv.error ?? 'Could not load payslip');
      }

      final recentEnv = await _client.fetchPayslips(page: 1, limit: 5);
      if (!recentEnv.success || recentEnv.data == null) {
        throw Exception(recentEnv.error ?? 'Could not load payslips');
      }

      emit(
        EmployeePayslipState(
          monthPayslips: monthEnv.data!.map(summaryFromJson).toList(),
          recentPayslips: recentEnv.data!.map(summaryFromJson).toList(),
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        EmployeePayslipState(
          monthPayslips: state.monthPayslips,
          recentPayslips: state.recentPayslips,
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }
}
