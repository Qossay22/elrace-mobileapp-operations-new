import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_api_client.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_session_cache.dart';
import 'package:el_race/ui/presentation/my_projects/data/datasources/project_remote_datasource.dart';
import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeMyProjectsWidgetCubit extends Cubit<MyProjectsWidgetRecord> {
  HomeMyProjectsWidgetCubit() : super(_instant()) {
    refresh();
  }

  Future<void> refresh({bool force = false}) async {
    await HomeWidgetApiClient.refreshIfStale(
      force: force || !HomeWidgetSessionCache.isFresh,
    );
    final raw = HomeWidgetSessionCache.myProjectsRaw;
    var record = raw != null ? MyProjectsWidgetRecord.fromMap(raw) : state;
    if (record.topProjects.isEmpty) {
      record = await _enrichTopProjects(record);
    }
    if (!isClosed) emit(record);
  }

  static MyProjectsWidgetRecord _instant() {
    return _myProjectsFromLogin() ??
        HomeWidgetSessionCache.myProjectsRaw
            ?.let(MyProjectsWidgetRecord.fromMap) ??
        MyProjectsWidgetRecord.empty();
  }

  Future<MyProjectsWidgetRecord> _enrichTopProjects(
    MyProjectsWidgetRecord record,
  ) async {
    try {
      final projects = await ProjectRemoteDataSource().fetchProjects(
        maxItems: 3,
      );
      if (projects.isEmpty) return record;

      final top = projects
          .map(
            (p) => MyProjectsTopProject(
              id: p.projectId,
              name: p.name,
              progressPct: p.totalProgress ?? 0,
              statusColor: 'mid',
              isOverdue: false,
            ),
          )
          .toList(growable: false);

      final total =
          record.totalActive > 0 ? record.totalActive : projects.length;
      return MyProjectsWidgetRecord(
        totalActive: total,
        dueThisWeekCount: record.dueThisWeekCount,
        topProjects: top,
        moreProjectsCount: total > top.length ? total - top.length : 0,
      );
    } catch (_) {
      return record;
    }
  }
}

class HomeSiteManagementWidgetCubit extends Cubit<SiteManagementWidgetRecord> {
  HomeSiteManagementWidgetCubit() : super(_instant()) {
    refresh();
  }

  Future<void> refresh({bool force = false}) async {
    await HomeWidgetApiClient.refreshIfStale(
      force: force || !HomeWidgetSessionCache.isFresh,
    );
    final raw = HomeWidgetSessionCache.siteManagementRaw;
    if (raw != null && !isClosed) {
      emit(SiteManagementWidgetRecord.fromMap(raw));
    }
  }

  static SiteManagementWidgetRecord _instant() {
    return _siteFromLogin() ??
        HomeWidgetSessionCache.siteManagementRaw
            ?.let(SiteManagementWidgetRecord.fromMap) ??
        SiteManagementWidgetRecord.empty();
  }
}

class HomeMyReportsWidgetCubit extends Cubit<MyReportsWidgetRecord> {
  HomeMyReportsWidgetCubit() : super(_instant()) {
    refresh();
  }

  Future<void> refresh({bool force = false}) async {
    await HomeWidgetApiClient.refreshIfStale(
      force: force || !HomeWidgetSessionCache.isFresh,
    );
    final raw = HomeWidgetSessionCache.myReportsRaw;
    if (raw != null && !isClosed) {
      emit(MyReportsWidgetRecord.fromMap(raw));
    }
  }

  static MyReportsWidgetRecord _instant() {
    return _reportsFromLogin() ??
        HomeWidgetSessionCache.myReportsRaw
            ?.let(MyReportsWidgetRecord.fromMap) ??
        MyReportsWidgetRecord.empty();
  }
}

MyProjectsWidgetRecord? _myProjectsFromLogin() {
  return SharedPref.getLoginData()
      .result
      ?.data
      ?.defaultWidgets
      ?.data
      ?.myProjectsWidget
      ?.myProjectsRecord;
}

SiteManagementWidgetRecord? _siteFromLogin() {
  return SharedPref.getLoginData()
      .result
      ?.data
      ?.defaultWidgets
      ?.data
      ?.siteManagementWidget
      ?.siteManagementRecord;
}

MyReportsWidgetRecord? _reportsFromLogin() {
  return SharedPref.getLoginData()
      .result
      ?.data
      ?.defaultWidgets
      ?.data
      ?.myReportsWidget
      ?.myReportsRecord;
}

extension _Let<T> on T {
  R let<R>(R Function(T value) fn) => fn(this);
}
