import 'package:bloc/bloc.dart';
import 'package:el_race/data/models/announcement_details_model.dart';
import 'package:el_race/data/services/announcements_api_service.dart';

import 'home_slider_event.dart';
import 'home_slider_state.dart';

class HomeSliderBloc extends Bloc<HomeSliderEvent, HomeSliderState> {
  HomeSliderBloc({
    AnnouncementsApiService? apiService,
  })  : _apiService = apiService ?? AnnouncementsApiService(),
        super(HomeSliderState(
          lastFetchTimestamp: DateTime.now().millisecondsSinceEpoch,
        )) {
    on<HomeSliderRequested>(_onRequested);
    on<HomeSliderRefreshRequested>(_onRefreshRequested);
    on<HomeSliderIndexChanged>(_onIndexChanged);
  }

  final AnnouncementsApiService _apiService;

  Future<void> _onRequested(
    HomeSliderRequested event,
    Emitter<HomeSliderState> emit,
  ) async {
    await _fetchAnnouncements(emit);
  }

  Future<void> _onRefreshRequested(
    HomeSliderRefreshRequested event,
    Emitter<HomeSliderState> emit,
  ) async {
    await _fetchAnnouncements(emit);
  }

  void _onIndexChanged(
    HomeSliderIndexChanged event,
    Emitter<HomeSliderState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }

  Future<void> _fetchAnnouncements(Emitter<HomeSliderState> emit) async {
    emit(state.copyWith(
      status: HomeSliderStatus.loading,
      clearErrorMessage: true,
    ));

    try {
      final announcements = await _apiService.fetchAnnouncements(
        category: AnnouncementCategory.news,
      );

      final bannerDetails = announcements
          .map(
            (item) => AnnouncementDetailsModel(
              id: item.id,
              title: item.name,
              announcementText: item.description,
              hasAttachment: item.hasAttachment,
              attachmentUrl: item.attachmentUrl,
            ),
          )
          .toList(growable: false);

      final currentIndex =
          state.currentIndex >= bannerDetails.length && bannerDetails.isNotEmpty
              ? 0
              : state.currentIndex;

      emit(state.copyWith(
        status: HomeSliderStatus.loaded,
        announcements: announcements,
        bannerDetails: bannerDetails,
        lastFetchTimestamp: DateTime.now().millisecondsSinceEpoch,
        currentIndex: currentIndex,
        clearErrorMessage: true,
      ));
    } on AnnouncementApiException catch (error) {
      emit(state.copyWith(
        status: HomeSliderStatus.error,
        announcements: const [],
        bannerDetails: const [],
        errorMessage: error.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: HomeSliderStatus.error,
        announcements: const [],
        bannerDetails: const [],
        errorMessage: 'Failed to load banner data',
      ));
    }
  }
}
