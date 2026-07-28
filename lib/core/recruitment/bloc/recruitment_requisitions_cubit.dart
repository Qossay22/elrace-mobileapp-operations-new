import 'package:el_race/core/recruitment/models/requisition.dart';
import 'package:el_race/core/recruitment/network/recruitment_api_client.dart';
import 'package:el_race/core/recruitment/network/recruitment_client_factory.dart';
import 'package:el_race/core/recruitment/recruitment_json_parsers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecruitmentRequisitionsState {
  const RecruitmentRequisitionsState({
    required this.items,
    this.isLoading = false,
    this.error,
  });

  final List<Requisition> items;
  final bool isLoading;
  final String? error;

  static const initial = RecruitmentRequisitionsState(items: <Requisition>[]);
}

class RecruitmentRequisitionsCubit extends Cubit<RecruitmentRequisitionsState> {
  RecruitmentRequisitionsCubit({RecruitmentApiClient? client})
      : _client = client ?? createRecruitmentApiClient(),
        super(RecruitmentRequisitionsState.initial);

  final RecruitmentApiClient _client;
  bool _hasLoaded = false;

  Future<void> load({bool force = false}) async {
    if (!force && (_hasLoaded || state.isLoading)) return;
    _hasLoaded = true;
    await refresh();
  }

  Future<void> refresh() async {
    emit(RecruitmentRequisitionsState(items: state.items, isLoading: true));
    try {
      final env = await _client.fetchRequisitions();
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not load requisitions');
      }
      emit(
        RecruitmentRequisitionsState(
          items: env.data!.map(requisitionFromJson).toList(),
        ),
      );
    } catch (e) {
      emit(
        RecruitmentRequisitionsState(
          items: state.items,
          error: e.toString(),
        ),
      );
    }
  }
}
