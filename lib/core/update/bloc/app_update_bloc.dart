import 'package:bloc/bloc.dart';
import 'package:el_race/core/services/update_service.dart';
import 'package:el_race/core/update/bloc/app_update_event.dart';
import 'package:el_race/core/update/bloc/app_update_state.dart';

class AppUpdateBloc extends Bloc<AppUpdateEvent, AppUpdateState> {
  AppUpdateBloc({UpdateService? updateService})
      : _updateService = updateService ?? UpdateService.instance,
        super(const AppUpdateState.initial()) {
    on<AppUpdateCheckRequested>(_onCheckRequested);
    on<AppRequiredUpdateStarted>(_onRequiredUpdateStarted);
  }

  final UpdateService _updateService;

  Future<void> _onCheckRequested(
    AppUpdateCheckRequested event,
    Emitter<AppUpdateState> emit,
  ) async {
    emit(state.copyWith(isChecking: true, clearError: true));

    final result = await _updateService
        .checkForUpdate()
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return const UpdateCheckResult.noUpdate();
    });

    emit(state.copyWith(
      isChecking: false,
      hasChecked: true,
      result: result,
      clearError: true,
    ));
  }

  Future<void> _onRequiredUpdateStarted(
    AppRequiredUpdateStarted event,
    Emitter<AppUpdateState> emit,
  ) async {
    if (!state.forceUpdateRequired || state.isStartingUpdate) return;

    emit(state.copyWith(isStartingUpdate: true, clearError: true));

    try {
      await _updateService.startRequiredUpdate(state.result);
      emit(state.copyWith(isStartingUpdate: false, clearError: true));
    } catch (error) {
      emit(state.copyWith(
        isStartingUpdate: false,
        errorMessage: 'Unable to open the update page. Please try again.',
      ));
    }
  }
}
