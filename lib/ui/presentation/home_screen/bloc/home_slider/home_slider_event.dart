import 'package:equatable/equatable.dart';

sealed class HomeSliderEvent extends Equatable {
  const HomeSliderEvent();

  @override
  List<Object?> get props => [];
}

final class HomeSliderRequested extends HomeSliderEvent {
  const HomeSliderRequested();
}

final class HomeSliderRefreshRequested extends HomeSliderEvent {
  const HomeSliderRefreshRequested();
}

final class HomeSliderIndexChanged extends HomeSliderEvent {
  const HomeSliderIndexChanged(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}
