import 'package:el_race/core/hr_management/models/hr_request_summary.dart';
import 'package:el_race/core/hr_management/network/hr_api_client.dart';
import 'package:el_race/core/hr_management/network/hr_api_client_factory.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HrTeamRequestsState {
  const HrTeamRequestsState({
    this.items = const [],
    this.kpis = const {},
    this.isLoading = false,
    this.error,
  });

  final List<HrRequestSummary> items;
  final Map<String, int> kpis;
  final bool isLoading;
  final String? error;

  static const initial = HrTeamRequestsState();
}

class HrTeamRequestsCubit extends Cubit<HrTeamRequestsState> {
  HrTeamRequestsCubit({HrApiClient? client})
      : _client = client ?? createHrApiClient(),
        super(HrTeamRequestsState.initial);

  final HrApiClient _client;

  Future<void> load({bool force = false}) async {
    if (!force && (state.isLoading || state.items.isNotEmpty)) {
      return;
    }
    emit(HrTeamRequestsState(
        items: state.items, kpis: state.kpis, isLoading: true));
    try {
      final teamEnv = await _client.fetchTeamRequests();
      if (!teamEnv.success || teamEnv.data == null) {
        emit(HrTeamRequestsState(
            error: teamEnv.error ?? 'Could not load team requests'));
        return;
      }

      final items = teamEnv.data!.map(HrRequestSummary.fromJson).toList();
      var kpis = _fallbackKpis(items);
      try {
        final kpiEnv = await _client.fetchTeamKpis(period: 'month');
        if (kpiEnv.success && kpiEnv.data != null) {
          final data = kpiEnv.data!;
          kpis = {
            'pending': (data['pending'] as num?)?.toInt() ?? kpis['pending']!,
            'approved':
                (data['approved'] as num?)?.toInt() ?? kpis['approved']!,
            'total': (data['total'] as num?)?.toInt() ?? kpis['total']!,
          };
        }
      } catch (_) {}

      emit(HrTeamRequestsState(items: items, kpis: kpis));
    } catch (e) {
      emit(HrTeamRequestsState(error: e.toString()));
    }
  }

  Future<void> refresh() => load(force: true);

  Map<String, int> _fallbackKpis(List<HrRequestSummary> items) {
    int count(String status) =>
        items.where((e) => e.uiStatus.toUpperCase() == status).length;
    return {
      'pending': count('PENDING'),
      'approved': count('APPROVED'),
      'total': items.length,
    };
  }
}
