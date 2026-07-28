import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_api_client.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_session_cache.dart';
import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Week-day chip state for the home attendance widget (Sun to Sat).
enum HomeAttendanceWeekDayState {
  present,
  absent,
  today,
  todayPresent,
  future,
  empty,
}

class HomeAttendanceWidgetData {
  const HomeAttendanceWidgetData({
    required this.presentDays,
    required this.workingDays,
    required this.attendancePercent,
    required this.weekDayStates,
  });

  final int presentDays;
  final int workingDays;
  final int attendancePercent;
  final List<HomeAttendanceWeekDayState> weekDayStates;

  static HomeAttendanceWidgetData? fromLoginCache() {
    final map = SharedPref.getLoginData()
        .result
        ?.data
        ?.defaultWidgets
        ?.data
        ?.attendanceWidget
        ?.recordMap;
    if (map == null) return null;

    final present = _readInt(map['present_days'] ?? map['present']);
    var working = _readInt(map['working_days']);
    if (working <= 0) {
      working = present + _readInt(map['absent']);
    }
    if (present <= 0 && working <= 0) return null;

    final pct = map['percentage'] != null
        ? _readInt(map['percentage'])
        : (working > 0 ? ((present / working) * 100).round() : 0);

    return HomeAttendanceWidgetData(
      presentDays: present,
      workingDays: working,
      attendancePercent: pct,
      weekDayStates: _defaultWeekStates(),
    );
  }

  static HomeAttendanceWidgetData? fromApiMap(Map<String, dynamic> map) {
    final present = _readInt(map['present_days'] ?? map['present']);
    final working = _readInt(map['working_days']);
    if (present <= 0 && working <= 0) return null;

    final pct = map['percentage'] != null
        ? _readInt(map['percentage'])
        : (working > 0 ? ((present / working) * 100).round() : 0);

    return HomeAttendanceWidgetData(
      presentDays: present,
      workingDays: working,
      attendancePercent: pct,
      weekDayStates: _defaultWeekStates(),
    );
  }

  static HomeAttendanceWidgetData empty() => HomeAttendanceWidgetData(
        presentDays: 0,
        workingDays: 0,
        attendancePercent: 0,
        weekDayStates: _defaultWeekStates(),
      );
}

class HomeHrmsWidgetData {
  const HomeHrmsWidgetData({
    required this.isManagerScope,
    required this.headlineCount,
    required this.headlineLabel,
    required this.trendLabel,
    required this.departmentName,
    required this.sectionName,
    required this.pendingRequests,
  });

  final bool isManagerScope;
  final int headlineCount;
  final String headlineLabel;
  final String trendLabel;
  final String? departmentName;
  final String? sectionName;
  final int pendingRequests;

  static HomeHrmsWidgetData? fromLoginCache() {
    final record = SharedPref.getLoginData()
        .result
        ?.data
        ?.defaultWidgets
        ?.data
        ?.hrmsWidget
        ?.hrmsRecord;
    if (record != null) return _fromHrmsRecord(record);

    final login = SharedPref.getLoginDataOrNull()?.result?.data;
    final pending = _readInt(login?.defaultWidgets?.data?.myRequestWidget
        ?.recordMap?['waiting_for_approval_count']);
    if (pending <= 0) return null;

    return HomeHrmsWidgetData(
      isManagerScope: false,
      headlineCount: pending,
      headlineLabel: 'EMPLOYEES',
      trendLabel:
          pending == 1 ? '1 pending request' : '$pending pending requests',
      departmentName: null,
      sectionName: null,
      pendingRequests: pending,
    );
  }

  static HomeHrmsWidgetData? fromApiMap(Map<String, dynamic> map) {
    final scope = map['scope']?.toString() ?? 'employee';
    final isManager = scope == 'manager' || scope == 'management';
    final direct = _readInt(map['direct_reports_count']);
    final allStaff = _readInt(map['all_staff_count']);
    final pending = _readInt(map['pending_requests_count']);
    final headlineRaw = _readInt(map['headline_count']);
    final headline = headlineRaw > 0
        ? headlineRaw
        : (scope == 'management'
            ? (allStaff > 0 ? allStaff : direct)
            : (isManager ? direct : pending));

    return HomeHrmsWidgetData(
      isManagerScope: isManager,
      headlineCount: headline,
      headlineLabel: 'EMPLOYEES',
      trendLabel: map['trend_label']?.toString() ??
          (scope == 'management'
              ? '$headline staff company-wide'
              : (isManager
                  ? '$direct under your team'
                  : (pending == 1
                      ? '1 pending request'
                      : pending > 0
                          ? '$pending pending requests'
                          : 'No pending requests'))),
      departmentName: _stringOrNull(map['department_name']),
      sectionName: _stringOrNull(map['section_name']),
      pendingRequests: pending,
    );
  }

  static HomeHrmsWidgetData empty() => const HomeHrmsWidgetData(
        isManagerScope: false,
        headlineCount: 0,
        headlineLabel: 'EMPLOYEES',
        trendLabel: 'Workforce overview',
        departmentName: null,
        sectionName: null,
        pendingRequests: 0,
      );
}

class HomeAttendanceWidgetCubit extends Cubit<HomeAttendanceWidgetData> {
  HomeAttendanceWidgetCubit() : super(_instant()) {
    refresh();
  }

  Future<void> refresh({bool force = false}) async {
    await HomeWidgetApiClient.refreshIfStale(
      force: force || !HomeWidgetSessionCache.isFresh,
    );
    final raw = HomeWidgetSessionCache.attendanceRaw;
    if (raw == null) return;
    final fresh = HomeAttendanceWidgetData.fromApiMap(raw);
    if (fresh != null && !isClosed) emit(fresh);
  }

  static HomeAttendanceWidgetData _instant() {
    return HomeAttendanceWidgetData.fromLoginCache() ??
        HomeWidgetSessionCache.attendanceRaw
            ?.let(HomeAttendanceWidgetData.fromApiMap) ??
        HomeAttendanceWidgetData.empty();
  }
}

class HomeHrmsWidgetCubit extends Cubit<HomeHrmsWidgetData> {
  HomeHrmsWidgetCubit() : super(_instant()) {
    refresh();
  }

  Future<void> refresh({bool force = false}) async {
    await HomeWidgetApiClient.refreshIfStale(
      force: force || !HomeWidgetSessionCache.isFresh,
    );
    final raw = HomeWidgetSessionCache.hrmsRaw;
    if (raw == null) return;
    final fresh = HomeHrmsWidgetData.fromApiMap(raw);
    if (fresh != null && !isClosed) emit(fresh);
  }

  static HomeHrmsWidgetData _instant() {
    return HomeHrmsWidgetData.fromLoginCache() ??
        HomeWidgetSessionCache.hrmsRaw?.let(HomeHrmsWidgetData.fromApiMap) ??
        HomeHrmsWidgetData.empty();
  }
}

HomeHrmsWidgetData _fromHrmsRecord(HrmsWidgetRecord record) {
  return HomeHrmsWidgetData(
    isManagerScope: record.isManagerScope,
    headlineCount: record.headlineCount,
    headlineLabel: 'EMPLOYEES',
    trendLabel: record.trendLabel,
    departmentName: record.departmentName,
    sectionName: record.sectionName,
    pendingRequests: record.pendingRequestsCount,
  );
}

List<HomeAttendanceWeekDayState> _defaultWeekStates() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: today.weekday % 7));

  return List.generate(7, (index) {
    final day = weekStart.add(Duration(days: index));
    if (day.isAfter(today)) return HomeAttendanceWeekDayState.future;
    if (day == today) return HomeAttendanceWeekDayState.today;
    return HomeAttendanceWeekDayState.empty;
  });
}

String? _stringOrNull(dynamic value) {
  if (value == null || value == false) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

int _readInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

extension _Let<T> on T {
  R? let<R>(R? Function(T value) fn) => fn(this);
}
