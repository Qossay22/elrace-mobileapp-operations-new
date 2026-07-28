import 'package:el_race/core/hr_management/hr_effective_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HrEffectiveViewState {
  const HrEffectiveViewState({
    required this.view,
    this.override,
  });

  final HrEffectiveView view;
  final HrEffectiveView? override;

  static HrEffectiveViewState fromLogin() {
    return HrEffectiveViewState(view: hrEffectiveViewFromLoginPref());
  }
}

class HrEffectiveViewCubit extends Cubit<HrEffectiveViewState> {
  HrEffectiveViewCubit() : super(HrEffectiveViewState.fromLogin());

  void refreshFromLogin() {
    if (state.override != null) {
      return;
    }
    emit(HrEffectiveViewState.fromLogin());
  }

  void setOverride(HrEffectiveView? view) {
    emit(
      HrEffectiveViewState(
        view: view ?? hrEffectiveViewFromLoginPref(),
        override: view,
      ),
    );
  }
}
