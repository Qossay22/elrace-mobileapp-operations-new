import 'package:el_race/core/services/update_service.dart';
import 'package:equatable/equatable.dart';

class AppUpdateState extends Equatable {
  final bool isChecking;
  final bool hasChecked;
  final bool isStartingUpdate;
  final UpdateCheckResult result;
  final String? errorMessage;

  const AppUpdateState({
    required this.isChecking,
    required this.hasChecked,
    required this.isStartingUpdate,
    required this.result,
    this.errorMessage,
  });

  const AppUpdateState.initial()
      : isChecking = false,
        hasChecked = false,
        isStartingUpdate = false,
        result = const UpdateCheckResult.noUpdate(),
        errorMessage = null;

  bool get forceUpdateRequired => result.forceUpdate;

  AppUpdateState copyWith({
    bool? isChecking,
    bool? hasChecked,
    bool? isStartingUpdate,
    UpdateCheckResult? result,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppUpdateState(
      isChecking: isChecking ?? this.isChecking,
      hasChecked: hasChecked ?? this.hasChecked,
      isStartingUpdate: isStartingUpdate ?? this.isStartingUpdate,
      result: result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isChecking,
        hasChecked,
        isStartingUpdate,
        result.updateAvailable,
        result.immediateUpdateAllowed,
        result.availableVersionCode,
        result.packageName,
        result.updateUrl,
        errorMessage,
      ];
}
