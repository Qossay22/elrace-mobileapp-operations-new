import 'package:bloc/bloc.dart';

import 'profile_box_event.dart';
import 'profile_box_state.dart';

class ProfileBoxBloc extends Bloc<ProfileBoxEvent, ProfileBoxState> {
  ProfileBoxBloc() : super(const ProfileBoxState()) {
    on<ProfileBoxToggled>(_onToggled);
    on<ProfileBoxHidden>(_onHidden);
    on<ProfileMuteNotificationsToggled>(_onMuteToggled);
    on<ProfileMuteNotificationsSet>(_onMuteSet);
  }

  void _onToggled(
    ProfileBoxToggled event,
    Emitter<ProfileBoxState> emit,
  ) {
    emit(state.copyWith(isProfileVisible: !state.isProfileVisible));
  }

  void _onHidden(
    ProfileBoxHidden event,
    Emitter<ProfileBoxState> emit,
  ) {
    emit(state.copyWith(isProfileVisible: false));
  }

  void _onMuteToggled(
    ProfileMuteNotificationsToggled event,
    Emitter<ProfileBoxState> emit,
  ) {
    emit(state.copyWith(muteNotifications: !state.muteNotifications));
  }

  void _onMuteSet(
    ProfileMuteNotificationsSet event,
    Emitter<ProfileBoxState> emit,
  ) {
    emit(state.copyWith(muteNotifications: event.value));
  }
}
