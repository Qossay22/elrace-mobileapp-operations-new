import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_api_client.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_session_cache.dart';
import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeTimesheetWidgetCubit extends Cubit<TimesheetWidgetRecord> {
  HomeTimesheetWidgetCubit() : super(_instant()) {
    refresh();
  }

  Future<void> refresh({bool force = false}) async {
    await HomeWidgetApiClient.refreshIfStale(
      force: force || !HomeWidgetSessionCache.isFresh,
    );
    final raw = HomeWidgetSessionCache.timesheetRaw;
    if (raw != null && !isClosed) {
      emit(TimesheetWidgetRecord.fromMap(raw));
    }
  }

  static TimesheetWidgetRecord _instant() {
    return _fromLoginCache() ??
        HomeWidgetSessionCache.timesheetRaw
            ?.let(TimesheetWidgetRecord.fromMap) ??
        _empty();
  }

  static TimesheetWidgetRecord? _fromLoginCache() {
    return SharedPref.getLoginData()
        .result
        ?.data
        ?.defaultWidgets
        ?.data
        ?.timesheetWidget
        ?.timesheetRecord;
  }

  static TimesheetWidgetRecord _empty() => const TimesheetWidgetRecord(
        totalHours: 0,
        overtimeHours: 0,
        avgPerWorker: 0,
        workersCount: 0,
        recordsCount: 0,
        projectsCount: 0,
        weekLabel: 'This Week',
        teamLabel: 'You',
        deltaVsLastWeek: 0,
        scope: 'self',
      );
}

extension _Let<T> on T {
  R let<R>(R Function(T value) fn) => fn(this);
}
