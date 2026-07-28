import 'package:el_race/data/services/announcements_api_service.dart';
import 'package:equatable/equatable.dart';

sealed class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

final class NewsRequested extends NewsEvent {
  const NewsRequested({
    this.category = AnnouncementCategory.news,
  });

  final AnnouncementCategory category;

  @override
  List<Object?> get props => [category];
}

final class NewsRefreshRequested extends NewsEvent {
  const NewsRefreshRequested();
}
