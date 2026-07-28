import 'package:el_race/ui/presentation/purchase_management/data/purchase_models.dart';
import 'package:el_race/ui/presentation/purchase_management/data/purchase_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MrDetailState {
  const MrDetailState({
    this.detail,
    this.loadedId,
    this.isLoading = false,
    this.error,
  });

  final MrDetail? detail;
  final int? loadedId;
  final bool isLoading;
  final String? error;

  static const initial = MrDetailState();
}

class MrDetailCubit extends Cubit<MrDetailState> {
  MrDetailCubit({PurchaseRepository? repository})
      : _repository = repository ?? PurchaseRepository(),
        super(MrDetailState.initial);

  final PurchaseRepository _repository;

  Future<void> load(int mrId, {bool force = false}) async {
    if (!force &&
        state.loadedId == mrId &&
        (state.isLoading || state.detail != null || state.error != null)) {
      return;
    }

    emit(
      MrDetailState(
        loadedId: mrId,
        detail: state.loadedId == mrId ? state.detail : null,
        isLoading: true,
      ),
    );

    try {
      final detail = await _repository.fetchRequisitionDetails(mrId);
      emit(MrDetailState(loadedId: mrId, detail: detail));
    } catch (e) {
      emit(MrDetailState(loadedId: mrId, error: e.toString()));
    }
  }
}
