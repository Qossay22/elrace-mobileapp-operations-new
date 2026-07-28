import 'package:el_race/data/models/announcement_model.dart';
import 'package:el_race/data/services/announcements_api_service.dart';
import 'package:equatable/equatable.dart';

enum NewsStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

final class NewsState extends Equatable {
  const NewsState({
    this.status = NewsStatus.initial,
    this.announcements = const [],
    this.currentCategory = AnnouncementCategory.news,
    this.errorMessage,
  });

  final NewsStatus status;
  final List<AnnouncementModel> announcements;
  final AnnouncementCategory currentCategory;
  final String? errorMessage;

  bool get isLoading => status == NewsStatus.loading;
  bool get hasData => status == NewsStatus.loaded && announcements.isNotEmpty;
  bool get isEmpty => status == NewsStatus.empty;
  bool get hasError => status == NewsStatus.error;

  NewsState copyWith({
    NewsStatus? status,
    List<AnnouncementModel>? announcements,
    AnnouncementCategory? currentCategory,
    String? errorMessage,
  }) {
    return NewsState(
      status: status ?? this.status,
      announcements: announcements ?? this.announcements,
      currentCategory: currentCategory ?? this.currentCategory,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        announcements,
        currentCategory,
        errorMessage,
      ];
}
