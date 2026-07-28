import 'package:el_race/data/models/announcement_details_model.dart';
import 'package:el_race/data/models/announcement_model.dart';
import 'package:equatable/equatable.dart';

enum HomeSliderStatus {
  initial,
  loading,
  loaded,
  error,
}

final class HomeSliderState extends Equatable {
  const HomeSliderState({
    this.status = HomeSliderStatus.initial,
    this.announcements = const [],
    this.bannerDetails = const [],
    this.errorMessage,
    this.lastFetchTimestamp = 0,
    this.currentIndex = 0,
  });

  static const List<String> fallbackImages = [
    'assets/jpeg/slide_1_c.jpg',
    'assets/jpeg/slide_2_c.jpg',
    'assets/jpeg/slide_3_c.jpg',
    'assets/jpeg/slide_4_c.jpg',
  ];

  static const List<String> fallbackTitles = [
    'The much-anticipated project has officially reached completion...',
    'Successfully delivered on schedule, the project highlights...',
    'Stakeholders have praised the project for its efficiency and...',
    'A closing ceremony was held to commemorate the achievement...',
  ];

  final HomeSliderStatus status;
  final List<AnnouncementModel> announcements;
  final List<AnnouncementDetailsModel> bannerDetails;
  final String? errorMessage;
  final int lastFetchTimestamp;
  final int currentIndex;

  bool get isLoading => status == HomeSliderStatus.loading;
  bool get hasError => status == HomeSliderStatus.error;
  bool get hasApiData => bannerDetails.isNotEmpty;

  List<String> get sliderImages {
    if (bannerDetails.isEmpty) {
      return fallbackImages;
    }
    return bannerDetails
        .map((detail) => detail.attachmentUrl ?? fallbackImages[0])
        .toList();
  }

  List<String> get titles {
    if (bannerDetails.isEmpty) {
      return fallbackTitles;
    }

    return bannerDetails.map((detail) {
      if (detail.announcementText.isNotEmpty) {
        return detail.announcementText.trim();
      } else if (detail.title.isNotEmpty) {
        return detail.title.trim();
      }
      return 'Announcement';
    }).toList();
  }

  AnnouncementModel announcementAt(int index) {
    if (announcements.isNotEmpty) {
      return announcements[index % announcements.length];
    }
    if (bannerDetails.isNotEmpty) {
      final detail = bannerDetails[index % bannerDetails.length];
      return AnnouncementModel(
        id: detail.id,
        name: detail.title.isNotEmpty ? detail.title : 'Announcement',
        description: detail.announcementText.isNotEmpty
            ? detail.announcementText
            : detail.title,
        hasAttachment: detail.hasAttachment,
        attachmentUrl: detail.attachmentUrl,
      );
    }
    final i = index % fallbackTitles.length;
    return AnnouncementModel(
      id: 0,
      name: fallbackTitles[i],
      description: fallbackTitles[i],
      hasAttachment: false,
      attachmentUrl: null,
    );
  }

  HomeSliderState copyWith({
    HomeSliderStatus? status,
    List<AnnouncementModel>? announcements,
    List<AnnouncementDetailsModel>? bannerDetails,
    String? errorMessage,
    bool clearErrorMessage = false,
    int? lastFetchTimestamp,
    int? currentIndex,
  }) {
    return HomeSliderState(
      status: status ?? this.status,
      announcements: announcements ?? this.announcements,
      bannerDetails: bannerDetails ?? this.bannerDetails,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      lastFetchTimestamp: lastFetchTimestamp ?? this.lastFetchTimestamp,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [
        status,
        announcements,
        bannerDetails,
        errorMessage,
        lastFetchTimestamp,
        currentIndex,
      ];
}
