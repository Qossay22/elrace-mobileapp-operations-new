import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_api_client.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_session_cache.dart';
import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePettyCashWidgetCubit extends Cubit<PettyCashWidgetRecord> {
  HomePettyCashWidgetCubit() : super(_instant()) {
    refresh();
  }

  Future<void> refresh({bool force = false}) async {
    await HomeWidgetApiClient.refreshIfStale(
      force: force || !HomeWidgetSessionCache.isFresh,
    );
    final raw = HomeWidgetSessionCache.pettyCashRaw;
    if (raw != null && !isClosed) {
      emit(PettyCashWidgetRecord.fromMap(raw));
    }
  }

  static PettyCashWidgetRecord _instant() {
    return _pettyCashFromLogin() ??
        HomeWidgetSessionCache.pettyCashRaw
            ?.let(PettyCashWidgetRecord.fromMap) ??
        PettyCashWidgetRecord.empty();
  }

  static PettyCashWidgetRecord? _pettyCashFromLogin() {
    return SharedPref.getLoginData()
        .result
        ?.data
        ?.defaultWidgets
        ?.data
        ?.pettyCashWidget
        ?.pettyCashRecord;
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T value) fn) => fn(this);
}
