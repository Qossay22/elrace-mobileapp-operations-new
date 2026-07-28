import 'package:el_race/core/home/home_widget_visibility.dart';
import 'package:el_race/ui/presentation/home_screen/providers/home_widget_api_client.dart';

/// Pull-to-refresh: refresh roles + widget card data.
///
/// Widget *visibility* is intentionally NOT refreshed here — it is resolved
/// once at login (from the login `default_widgets` payload) and only changes on
/// the next login. This keeps a single source of truth and avoids widgets
/// appearing/disappearing mid-session.
class HomeWidgetRefreshService {
  HomeWidgetRefreshService._();

  static Future<void> refresh() async {
    // Roles come from the login payload only and refresh on re-login —
    // no session-refresh call here (product decision 2026-07-20).
    final visible = visibleCategoryCodes();
    await HomeWidgetApiClient.refreshIfStale(
      force: true,
      onlyCodes: visible,
    );
  }

  /// Visible v7 category widgets after the latest pref merge.
  static Set<HomeWidgetCode> visibleCategoryCodes() {
    final visibility = HomeWidgetVisibility.fromLoginPref();
    return HomeWidgetCode.values.where(visibility.isVisible).toSet();
  }
}
