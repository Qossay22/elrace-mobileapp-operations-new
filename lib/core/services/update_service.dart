import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

/// Result of the app update availability check.
class UpdateCheckResult {
  final bool updateAvailable;
  final bool immediateUpdateAllowed;
  final int? availableVersionCode;
  final String? packageName;
  final String? updateUrl;

  const UpdateCheckResult({
    required this.updateAvailable,
    required this.immediateUpdateAllowed,
    this.availableVersionCode,
    this.packageName,
    this.updateUrl,
  });

  const UpdateCheckResult.noUpdate()
      : updateAvailable = false,
        immediateUpdateAllowed = false,
        availableVersionCode = null,
        packageName = null,
        updateUrl = null;

  bool get forceUpdate => updateAvailable;
}

/// Uses Google Play In-App Updates to detect mandatory Android app updates.
///
/// iOS and non-Android platforms fail open because the Play In-App Updates API
/// is Android-only.
class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  static const String _androidPackageName = 'ae.elrace.mobile';
  static const String _iosStoreUrl = 'https://apps.apple.com/app/id0000000000';

  Future<UpdateCheckResult> checkForUpdate([String? _]) async {
    if (!Platform.isAndroid) {
      return const UpdateCheckResult.noUpdate();
    }

    try {
      final info = await InAppUpdate.checkForUpdate();
      final updateAvailable =
          info.updateAvailability == UpdateAvailability.updateAvailable ||
              info.updateAvailability ==
                  UpdateAvailability.developerTriggeredUpdateInProgress;

      if (!updateAvailable) {
        return const UpdateCheckResult.noUpdate();
      }

      final packageName =
          info.packageName.isNotEmpty ? info.packageName : _androidPackageName;
      return UpdateCheckResult(
        updateAvailable: true,
        immediateUpdateAllowed: info.immediateUpdateAllowed ||
            info.updateAvailability ==
                UpdateAvailability.developerTriggeredUpdateInProgress,
        availableVersionCode: info.availableVersionCode,
        packageName: packageName,
        updateUrl: _androidStoreUrl(packageName),
      );
    } catch (error) {
      debugPrint('UpdateService: in-app update check failed: $error');
      return const UpdateCheckResult.noUpdate();
    }
  }

  Future<void> startRequiredUpdate(UpdateCheckResult result) async {
    if (Platform.isAndroid && result.immediateUpdateAllowed) {
      final updateResult = await InAppUpdate.performImmediateUpdate();
      if (updateResult == AppUpdateResult.success) {
        return;
      }
    }

    await openStore(result);
  }

  Future<void> openStore(UpdateCheckResult result) async {
    final rawUrl = result.updateUrl ??
        (Platform.isIOS ? _iosStoreUrl : _androidStoreUrl(_androidPackageName));
    final uri = Uri.parse(rawUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static String _androidStoreUrl(String packageName) {
    return 'https://play.google.com/store/apps/details?id=$packageName';
  }
}
