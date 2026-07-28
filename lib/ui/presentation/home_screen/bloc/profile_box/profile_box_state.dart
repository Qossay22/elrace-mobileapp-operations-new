import 'package:equatable/equatable.dart';

final class ProfileBoxState extends Equatable {
  const ProfileBoxState({
    this.isProfileVisible = false,
    this.muteNotifications = false,
  });

  final bool isProfileVisible;
  final bool muteNotifications;

  ProfileBoxState copyWith({
    bool? isProfileVisible,
    bool? muteNotifications,
  }) {
    return ProfileBoxState(
      isProfileVisible: isProfileVisible ?? this.isProfileVisible,
      muteNotifications: muteNotifications ?? this.muteNotifications,
    );
  }

  @override
  List<Object?> get props => [isProfileVisible, muteNotifications];
}
