import 'package:el_race/core/recruitment/network/recruitment_api_client.dart';
import 'package:el_race/core/recruitment/network/recruitment_client_factory.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecruitmentDashboardState {
  const RecruitmentDashboardState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  final Map<String, dynamic>? data;
  final bool isLoading;
  final String? error;

  static const initial = RecruitmentDashboardState();
}

class RecruitmentDashboardCubit extends Cubit<RecruitmentDashboardState> {
  RecruitmentDashboardCubit({RecruitmentApiClient? client})
      : _client = client ?? createRecruitmentApiClient(),
        super(RecruitmentDashboardState.initial);

  final RecruitmentApiClient _client;
  bool _hasLoaded = false;

  Future<void> load({bool force = false}) async {
    if (!force && (_hasLoaded || state.isLoading)) return;
    _hasLoaded = true;
    emit(RecruitmentDashboardState(data: state.data, isLoading: true));
    try {
      final env = await _client.fetchDashboard();
      if (!env.success || env.data == null) {
        throw Exception(env.error ?? 'Could not load dashboard');
      }
      emit(RecruitmentDashboardState(data: env.data!));
    } catch (e) {
      emit(RecruitmentDashboardState(data: state.data, error: e.toString()));
    }
  }
}
