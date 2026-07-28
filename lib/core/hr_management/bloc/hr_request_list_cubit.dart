import 'package:el_race/core/hr_management/models/hr_request_summary.dart';
import 'package:el_race/core/hr_management/network/hr_api_client.dart';
import 'package:el_race/core/hr_management/network/hr_api_client_factory.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HrRequestListState {
  const HrRequestListState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<HrRequestSummary> items;
  final bool isLoading;
  final String? error;

  static const initial = HrRequestListState();
}

class HrRequestListCubit extends Cubit<HrRequestListState> {
  HrRequestListCubit({HrApiClient? client})
      : _client = client ?? createHrApiClient(),
        super(HrRequestListState.initial);

  final HrApiClient _client;

  Future<void> load({bool force = false}) async {
    if (!force && (state.isLoading || state.items.isNotEmpty)) {
      return;
    }

    emit(HrRequestListState(items: state.items, isLoading: true));
    try {
      final env = await _client.fetchMyRequests();
      if (env.success && env.data != null) {
        emit(
          HrRequestListState(
            items: env.data!.map(HrRequestSummary.fromJson).toList(),
          ),
        );
        return;
      }
      emit(
          HrRequestListState(error: env.error ?? 'Could not load my requests'));
    } catch (e) {
      emit(HrRequestListState(error: e.toString()));
    }
  }

  Future<void> refresh() => load(force: true);
}
