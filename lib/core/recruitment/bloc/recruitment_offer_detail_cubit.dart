import 'package:el_race/core/recruitment/models/recruitment_entities.dart';
import 'package:el_race/core/recruitment/network/recruitment_api_client.dart';
import 'package:el_race/core/recruitment/network/recruitment_client_factory.dart';
import 'package:el_race/core/recruitment/recruitment_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecruitmentOfferDetailState {
  const RecruitmentOfferDetailState({
    this.detail,
    this.loadedId,
    this.isLoading = false,
    this.error,
  });

  final RecruitmentOfferDetail? detail;
  final String? loadedId;
  final bool isLoading;
  final String? error;

  static const initial = RecruitmentOfferDetailState();
}

class RecruitmentOfferDetailCubit extends Cubit<RecruitmentOfferDetailState> {
  RecruitmentOfferDetailCubit({RecruitmentApiClient? client})
      : _client = client ?? createRecruitmentApiClient(),
        super(RecruitmentOfferDetailState.initial);

  final RecruitmentApiClient _client;

  Future<void> load(String id, {bool force = false}) async {
    final normalizedId = id.trim();
    if (!force &&
        state.loadedId == normalizedId &&
        (state.isLoading || state.detail != null || state.error != null)) {
      return;
    }

    emit(
      RecruitmentOfferDetailState(
        loadedId: normalizedId,
        detail: state.loadedId == normalizedId ? state.detail : null,
        isLoading: true,
      ),
    );

    try {
      final env = await _client.fetchOfferDetail(normalizedId);
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not load offer');
      }
      emit(
        RecruitmentOfferDetailState(
          loadedId: normalizedId,
          detail: offerDetailFromJson(env.data!),
        ),
      );
    } catch (e) {
      emit(
        RecruitmentOfferDetailState(
          loadedId: normalizedId,
          error: e.toString(),
        ),
      );
    }
  }
}
