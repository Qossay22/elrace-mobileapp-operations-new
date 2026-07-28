import 'package:el_race/core/payslip/models/payslip_models.dart';
import 'package:el_race/core/payslip/payslip_mock_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingPayslipState {
  const PendingPayslipState({
    required this.count,
    required this.peek,
    this.isLoading = false,
    this.error,
  });

  final int count;
  final List<PayslipSummary> peek;
  final bool isLoading;
  final String? error;

  static const initial = PendingPayslipState(
    count: 0,
    peek: <PayslipSummary>[],
  );
}

class PendingPayslipCubit extends Cubit<PendingPayslipState> {
  PendingPayslipCubit() : super(PendingPayslipState.initial);

  Future<void> load({bool force = false}) async {
    if (!force &&
        (state.isLoading || state.count > 0 || state.peek.isNotEmpty)) {
      return;
    }

    emit(
      PendingPayslipState(
        count: state.count,
        peek: state.peek,
        isLoading: true,
      ),
    );

    try {
      emit(
        PendingPayslipState(
          count: payslipPendingCount(),
          peek: payslipPendingPage(page: 0, pageSize: 5),
        ),
      );
    } catch (e) {
      emit(
        PendingPayslipState(
          count: state.count,
          peek: state.peek,
          error: e.toString(),
        ),
      );
    }
  }
}
