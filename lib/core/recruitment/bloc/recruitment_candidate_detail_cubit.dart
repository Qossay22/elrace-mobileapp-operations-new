import 'package:el_race/core/recruitment/models/recruitment_entities.dart';
import 'package:el_race/core/recruitment/network/recruitment_api_client.dart';
import 'package:el_race/core/recruitment/network/recruitment_client_factory.dart';
import 'package:el_race/core/recruitment/recruitment_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecruitmentCandidateDetailState {
  const RecruitmentCandidateDetailState({
    this.candidate,
    this.loadedId,
    this.isLoading = false,
    this.error,
  });

  final RecruitmentCandidate? candidate;
  final String? loadedId;
  final bool isLoading;
  final String? error;

  static const initial = RecruitmentCandidateDetailState();
}

class RecruitmentCandidateDetailCubit
    extends Cubit<RecruitmentCandidateDetailState> {
  RecruitmentCandidateDetailCubit({RecruitmentApiClient? client})
      : _client = client ?? createRecruitmentApiClient(),
        super(RecruitmentCandidateDetailState.initial);

  final RecruitmentApiClient _client;

  Future<void> load(String id, {bool force = false}) async {
    final normalizedId = id.trim();
    if (!force &&
        state.loadedId == normalizedId &&
        (state.isLoading || state.candidate != null || state.error != null)) {
      return;
    }
    emit(
      RecruitmentCandidateDetailState(
        loadedId: normalizedId,
        candidate: state.loadedId == normalizedId ? state.candidate : null,
        isLoading: true,
      ),
    );
    try {
      final env = await _client.fetchCandidateDetail(normalizedId);
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not load candidate');
      }
      emit(
        RecruitmentCandidateDetailState(
          loadedId: normalizedId,
          candidate: candidateFromJson(env.data!),
        ),
      );
    } catch (e) {
      emit(
        RecruitmentCandidateDetailState(
          loadedId: normalizedId,
          error: e.toString(),
        ),
      );
    }
  }
}
