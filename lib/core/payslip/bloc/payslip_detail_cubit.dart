import 'package:el_race/core/payslip/models/payslip_models.dart';
import 'package:el_race/core/payslip/network/payslip_api_client.dart';
import 'package:el_race/core/payslip/network/payslip_client_factory.dart';
import 'package:el_race/core/payslip/payslip_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PayslipDetailState {
  const PayslipDetailState({
    this.record,
    this.loadedId,
    this.isLoading = false,
    this.error,
  });

  final PayslipRecord? record;
  final String? loadedId;
  final bool isLoading;
  final String? error;

  static const initial = PayslipDetailState();
}

class PayslipDetailCubit extends Cubit<PayslipDetailState> {
  PayslipDetailCubit({PayslipApiClient? client})
      : _client = client ?? createPayslipApiClient(),
        super(PayslipDetailState.initial);

  final PayslipApiClient _client;

  Future<void> load(String id, {bool force = false}) async {
    final normalizedId = id.trim();
    if (!force &&
        state.loadedId == normalizedId &&
        (state.isLoading || state.record != null || state.error != null)) {
      return;
    }

    final parsedId = int.tryParse(normalizedId);
    if (parsedId == null || parsedId <= 0) {
      emit(
        PayslipDetailState(
          loadedId: normalizedId,
          error: 'Invalid payslip id',
        ),
      );
      return;
    }

    emit(
      PayslipDetailState(
        record: state.loadedId == normalizedId ? state.record : null,
        loadedId: normalizedId,
        isLoading: true,
      ),
    );

    try {
      final env = await _client
          .fetchPayslipDetail(normalizedId)
          .timeout(const Duration(seconds: 30));
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not load payslip');
      }

      emit(
        PayslipDetailState(
          loadedId: normalizedId,
          record: recordFromJson(env.data!),
        ),
      );
    } catch (e) {
      emit(
        PayslipDetailState(
          loadedId: normalizedId,
          error: e.toString(),
        ),
      );
    }
  }
}
