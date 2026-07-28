import 'package:el_race/core/recruitment/models/recruitment_entities.dart';
import 'package:el_race/core/recruitment/network/recruitment_api_client.dart';
import 'package:el_race/core/recruitment/network/recruitment_client_factory.dart';
import 'package:el_race/core/recruitment/recruitment_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecruitmentCandidatesState {
  const RecruitmentCandidatesState({
    required this.items,
    this.isLoading = false,
    this.error,
  });

  final List<RecruitmentCandidate> items;
  final bool isLoading;
  final String? error;

  static const initial =
      RecruitmentCandidatesState(items: <RecruitmentCandidate>[]);
}

class RecruitmentCandidatesCubit extends Cubit<RecruitmentCandidatesState> {
  RecruitmentCandidatesCubit({RecruitmentApiClient? client})
      : _client = client ?? createRecruitmentApiClient(),
        super(RecruitmentCandidatesState.initial);

  final RecruitmentApiClient _client;
  bool _hasLoaded = false;

  Future<void> load({bool force = false}) async {
    if (!force && (_hasLoaded || state.isLoading)) return;
    _hasLoaded = true;
    await refresh();
  }

  Future<void> refresh() async {
    emit(RecruitmentCandidatesState(items: state.items, isLoading: true));
    try {
      final env = await _client.fetchCandidates();
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not load candidates');
      }
      emit(
        RecruitmentCandidatesState(
          items: env.data!.map(candidateFromJson).toList(),
        ),
      );
    } catch (e) {
      emit(RecruitmentCandidatesState(items: state.items, error: e.toString()));
    }
  }
}
