import 'package:equatable/equatable.dart';

sealed class ProfileBoxEvent extends Equatable {
  const ProfileBoxEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileBoxToggled extends ProfileBoxEvent {
  const ProfileBoxToggled();
}

final class ProfileBoxHidden extends ProfileBoxEvent {
  const ProfileBoxHidden();
}

final class ProfileMuteNotificationsToggled extends ProfileBoxEvent {
  const ProfileMuteNotificationsToggled();
}

final class ProfileMuteNotificationsSet extends ProfileBoxEvent {
  const ProfileMuteNotificationsSet(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}
