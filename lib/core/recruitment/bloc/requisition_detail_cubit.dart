import 'package:el_race/core/recruitment/models/recruitment_entities.dart';
import 'package:el_race/core/recruitment/network/recruitment_api_client.dart';
import 'package:el_race/core/recruitment/network/recruitment_client_factory.dart';
import 'package:el_race/core/recruitment/recruitment_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequisitionDetailState {
  const RequisitionDetailState({
    this.detail,
    this.loadedId,
    this.isLoading = false,
    this.error,
  });

  final RequisitionDetailModel? detail;
  final String? loadedId;
  final bool isLoading;
  final String? error;

  static const initial = RequisitionDetailState();
}

class RequisitionDetailCubit extends Cubit<RequisitionDetailState> {
  RequisitionDetailCubit({RecruitmentApiClient? client})
      : _client = client ?? createRecruitmentApiClient(),
        super(RequisitionDetailState.initial);

  final RecruitmentApiClient _client;

  Future<void> load(String id, {bool force = false}) async {
    final normalizedId = id.trim();
    if (!force &&
        state.loadedId == normalizedId &&
        (state.isLoading || state.detail != null || state.error != null)) {
      return;
    }
    emit(
      RequisitionDetailState(
        loadedId: normalizedId,
        detail: state.loadedId == normalizedId ? state.detail : null,
        isLoading: true,
      ),
    );

    try {
      final env = await _client.fetchRequisitionDetail(normalizedId);
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not load requisition');
      }
      emit(
        RequisitionDetailState(
          loadedId: normalizedId,
          detail: requisitionDetailFromJson(env.data!),
        ),
      );
    } catch (e) {
      emit(RequisitionDetailState(loadedId: normalizedId, error: e.toString()));
    }
  }
}
