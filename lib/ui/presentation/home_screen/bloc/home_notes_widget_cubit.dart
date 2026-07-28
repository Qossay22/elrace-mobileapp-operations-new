import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_api_client.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_session_cache.dart';
import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeNotesWidgetCubit extends Cubit<NotesWidgetRecord> {
  HomeNotesWidgetCubit() : super(_instant()) {
    refresh();
  }

  Future<void> refresh({bool force = false}) async {
    await HomeWidgetApiClient.refreshIfStale(
      force: force || !HomeWidgetSessionCache.isFresh,
    );
    final raw = HomeWidgetSessionCache.notesRaw;
    if (raw != null && !isClosed) {
      emit(NotesWidgetRecord.fromMap(raw));
    }
  }

  static NotesWidgetRecord _instant() {
    return _notesFromLogin() ??
        HomeWidgetSessionCache.notesRaw?.let(NotesWidgetRecord.fromMap) ??
        NotesWidgetRecord.empty();
  }

  static NotesWidgetRecord? _notesFromLogin() {
    return SharedPref.getLoginData()
        .result
        ?.data
        ?.defaultWidgets
        ?.data
        ?.myNotesWidget
        ?.notesRecord;
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T value) fn) => fn(this);
}
