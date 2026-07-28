import 'package:el_race/core/purchase/purchase_dev_role_provider.dart';
import 'package:el_race/ui/presentation/purchase_management/data/purchase_models.dart';
import 'package:el_race/ui/presentation/purchase_management/data/purchase_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceReceivingDetailState {
  const InvoiceReceivingDetailState({
    this.detail,
    this.loadedId,
    this.isLoading = false,
    this.isReceiving = false,
    this.error,
  });

  final InvoiceReceivingDetail? detail;
  final int? loadedId;
  final bool isLoading;
  final bool isReceiving;
  final String? error;

  static const initial = InvoiceReceivingDetailState();
}

class InvoiceReceivingDetailCubit extends Cubit<InvoiceReceivingDetailState> {
  InvoiceReceivingDetailCubit({PurchaseRepository? repository})
      : _repository = repository ?? PurchaseRepository(),
        super(InvoiceReceivingDetailState.initial);

  final PurchaseRepository _repository;
  PurchaseDevTestRole? _testRole;

  Future<void> load(
    int invoiceId, {
    PurchaseDevTestRole? testRole,
    bool force = false,
  }) async {
    _testRole = testRole;
    if (!force &&
        state.loadedId == invoiceId &&
        (state.isLoading || state.detail != null || state.error != null)) {
      return;
    }

    emit(
      InvoiceReceivingDetailState(
        loadedId: invoiceId,
        detail: state.loadedId == invoiceId ? state.detail : null,
        isLoading: true,
      ),
    );

    try {
      final detail = await _repository.fetchInvoiceReceivingDetails(
        invoiceId,
        testRole: testRole,
      );
      emit(InvoiceReceivingDetailState(loadedId: invoiceId, detail: detail));
    } catch (e) {
      emit(
        InvoiceReceivingDetailState(
          loadedId: invoiceId,
          error: e.toString(),
        ),
      );
    }
  }

  Future<bool> receive(int invoiceId) async {
    emit(
      InvoiceReceivingDetailState(
        loadedId: invoiceId,
        detail: state.detail,
        isReceiving: true,
      ),
    );
    try {
      final updated = await _repository.receiveInvoiceReceiving(
        invoiceId,
        testRole: _testRole,
      );
      if (updated == null) {
        emit(
          InvoiceReceivingDetailState(
            loadedId: invoiceId,
            detail: state.detail,
            error: 'Receive failed. Check PR role.',
          ),
        );
        return false;
      }
      final detail = await _repository.fetchInvoiceReceivingDetails(
        invoiceId,
        testRole: _testRole,
      );
      emit(InvoiceReceivingDetailState(loadedId: invoiceId, detail: detail));
      return true;
    } catch (e) {
      emit(
        InvoiceReceivingDetailState(
          loadedId: invoiceId,
          detail: state.detail,
          error: e.toString(),
        ),
      );
      return false;
    }
  }
}
