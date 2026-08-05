import 'package:equatable/equatable.dart';

abstract class AppUpdateEvent extends Equatable {
  const AppUpdateEvent();

  @override
  List<Object?> get props => [];
}

class AppUpdateCheckRequested extends AppUpdateEvent {
  const AppUpdateCheckRequested();
}

class AppRequiredUpdateStarted extends AppUpdateEvent {
  const AppRequiredUpdateStarted();
}
