import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_api_client.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_session_cache.dart';
import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeLpoWidgetCubit extends Cubit<LpoWidgetRecord> {
  HomeLpoWidgetCubit() : super(_instant()) {
    refresh();
  }

  Future<void> refresh({bool force = false}) async {
    await HomeWidgetApiClient.refreshIfStale(
      force: force || !HomeWidgetSessionCache.isFresh,
    );
    final raw = HomeWidgetSessionCache.lpoRaw;
    if (raw != null && !isClosed) {
      emit(LpoWidgetRecord.fromMap(raw));
    }
  }

  static LpoWidgetRecord _instant() {
    return _lpoFromLogin() ??
        HomeWidgetSessionCache.lpoRaw?.let(LpoWidgetRecord.fromMap) ??
        LpoWidgetRecord.empty();
  }

  static LpoWidgetRecord? _lpoFromLogin() {
    return SharedPref.getLoginData()
        .result
        ?.data
        ?.defaultWidgets
        ?.data
        ?.lpoWidget
        ?.lpoRecord;
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T value) fn) => fn(this);
}
