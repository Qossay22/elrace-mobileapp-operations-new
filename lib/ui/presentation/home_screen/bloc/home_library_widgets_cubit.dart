import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_api_client.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_session_cache.dart';
import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeMyDocumentsWidgetCubit extends Cubit<MyDocumentsWidgetRecord> {
  HomeMyDocumentsWidgetCubit() : super(_instant()) {
    refresh();
  }

  Future<void> refresh({bool force = false}) async {
    await HomeWidgetApiClient.refreshIfStale(
      force: force || !HomeWidgetSessionCache.isFresh,
    );
    final raw = HomeWidgetSessionCache.myDocumentsRaw;
    if (raw != null && !isClosed) {
      emit(MyDocumentsWidgetRecord.fromMap(raw));
    }
  }

  static MyDocumentsWidgetRecord _instant() {
    return _myDocumentsFromLogin() ??
        HomeWidgetSessionCache.myDocumentsRaw
            ?.let(MyDocumentsWidgetRecord.fromMap) ??
        MyDocumentsWidgetRecord.empty();
  }
}

class HomeMediaWidgetCubit extends Cubit<MediaWidgetRecord> {
  HomeMediaWidgetCubit() : super(_instant()) {
    refresh();
  }

  Future<void> refresh({bool force = false}) async {
    await HomeWidgetApiClient.refreshIfStale(
      force: force || !HomeWidgetSessionCache.isFresh,
    );
    final raw = HomeWidgetSessionCache.mediaRaw;
    if (raw != null && !isClosed) {
      emit(MediaWidgetRecord.fromMap(raw));
    }
  }

  static MediaWidgetRecord _instant() {
    return _mediaFromLogin() ??
        HomeWidgetSessionCache.mediaRaw?.let(MediaWidgetRecord.fromMap) ??
        MediaWidgetRecord.empty();
  }
}

MyDocumentsWidgetRecord? _myDocumentsFromLogin() {
  return SharedPref.getLoginData()
      .result
      ?.data
      ?.defaultWidgets
      ?.data
      ?.myDocumentsWidget
      ?.myDocumentsRecord;
}

MediaWidgetRecord? _mediaFromLogin() {
  return SharedPref.getLoginData()
      .result
      ?.data
      ?.defaultWidgets
      ?.data
      ?.mediaWidget
      ?.mediaRecord;
}

extension _Let<T> on T {
  R let<R>(R Function(T value) fn) => fn(this);
}
