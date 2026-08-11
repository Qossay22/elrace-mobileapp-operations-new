import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:el_race/core/services/android_play_update_service.dart';
import 'package:el_race/utils/urll_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateCheckResult {
  final bool forceUpdate;
  final bool optionalUpdate;
  final String? latestVersion;
  final String? minVersion;
  final String? updateUrl;
  final String? updateMessageEn;
  final String? updateMessageAr;

  const UpdateCheckResult({
    required this.forceUpdate,
    required this.optionalUpdate,
    this.latestVersion,
    this.minVersion,
    this.updateUrl,
    this.updateMessageEn,
    this.updateMessageAr,
  });

  const UpdateCheckResult.noUpdate()
      : forceUpdate = false,
        optionalUpdate = false,
        latestVersion = null,
        minVersion = null,
        updateUrl = null,
        updateMessageEn = null,
        updateMessageAr = null;

  bool get updateAvailable => forceUpdate || optionalUpdate;
}

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  Future<UpdateCheckResult> checkForUpdate([String? currentVersion]) async {
    try {
      final resolvedVersion = currentVersion ?? await _readCurrentVersion();
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {'Content-Type': 'application/json'},
      ));

      const url = '${UrlUtil.baseUrl}app/config';
      final resp = await dio.get(
        url,
        data: {'jsonrpc': '2.0', 'params': {}},
      );

      final payload = _extractPayload(resp.data);
      if (payload == null) return const UpdateCheckResult.noUpdate();

      return buildResultFromPayload(
        payload: payload,
        currentVersion: resolvedVersion,
      );
    } catch (e) {
      debugPrint('UpdateService: update check failed open: $e');
      return const UpdateCheckResult.noUpdate();
    }
  }

  Future<void> startRequiredUpdate(UpdateCheckResult result) async {
    if (Platform.isAndroid) {
      final started = await AndroidPlayUpdateService.instance
          .startImmediateUpdateIfAvailable();
      if (started) return;
    }

    await openStore(result);
  }

  Future<void> openStore(UpdateCheckResult result) async {
    final urls = _candidateStoreUrls(result.updateUrl);
    for (final rawUrl in urls) {
      final uri = Uri.tryParse(rawUrl);
      if (uri == null) continue;
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    }
  }

  UpdateCheckResult buildResultFromPayload({
    required Map<String, dynamic> payload,
    required String currentVersion,
  }) {
    final minVersionStr = _readString(
      payload,
      const ['minVersion', 'min_version', 'minimumVersion', 'minimum_version'],
    );
    final latestVersionStr = _readString(
      payload,
      const ['latestVersion', 'latest_version', 'version', 'appVersion'],
    );
    final updateUrl = _readString(
      payload,
      const [
        'updateUrl',
        'update_url',
        'storeUrl',
        'store_url',
        'appStoreUrl',
        'playStoreUrl',
      ],
    );
    final updateMessageEn = _readString(
      payload,
      const ['updateMessageEn', 'update_message_en', 'messageEn', 'message_en'],
    );
    final updateMessageAr = _readString(
      payload,
      const ['updateMessageAr', 'update_message_ar', 'messageAr', 'message_ar'],
    );
    final explicitForceUpdate = _readBool(
      payload,
      const [
        'forceUpdate',
        'force_update',
        'mandatoryUpdate',
        'requiredUpdate',
      ],
    );

    if (minVersionStr == null &&
        latestVersionStr == null &&
        explicitForceUpdate != true) {
      return const UpdateCheckResult.noUpdate();
    }

    final current = parseVersion(currentVersion);
    var forceUpdate = false;
    var optionalUpdate = false;

    if (minVersionStr != null) {
      final min = parseVersion(minVersionStr);
      forceUpdate = compareVersions(current, min) < 0;
    }

    if (!forceUpdate &&
        explicitForceUpdate == true &&
        latestVersionStr != null) {
      final latest = parseVersion(latestVersionStr);
      forceUpdate = compareVersions(current, latest) < 0;
    }

    if (!forceUpdate && latestVersionStr != null) {
      final latest = parseVersion(latestVersionStr);
      optionalUpdate = compareVersions(current, latest) < 0;
    }

    return UpdateCheckResult(
      forceUpdate: forceUpdate,
      optionalUpdate: optionalUpdate,
      latestVersion: latestVersionStr,
      minVersion: minVersionStr,
      updateUrl: updateUrl,
      updateMessageEn: updateMessageEn,
      updateMessageAr: updateMessageAr,
    );
  }

  List<int> parseVersion(String version) {
    final clean = version.split('+').first.split('-').first.trim();
    return clean.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  }

  int compareVersions(List<int> a, List<int> b) {
    final length = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < length; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av != bv) return av - bv;
    }
    return 0;
  }

  Future<String> _readCurrentVersion() async {
    final info =
        await PackageInfo.fromPlatform().timeout(const Duration(seconds: 3));
    if (info.version.trim().isNotEmpty) return info.version;
    return '${info.version}+${info.buildNumber}';
  }

  Map<String, dynamic>? _extractPayload(Object? data) {
    if (data is Map<String, dynamic>) {
      return data['result'] is Map<String, dynamic>
          ? data['result'] as Map<String, dynamic>
          : data;
    }
    if (data is String) {
      try {
        final parsed = jsonDecode(data);
        if (parsed is Map<String, dynamic>) {
          return parsed['result'] is Map<String, dynamic>
              ? parsed['result'] as Map<String, dynamic>
              : parsed;
        }
      } catch (_) {}
    }
    return null;
  }

  String? _readString(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  bool? _readBool(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
          return true;
        }
        if (normalized == 'false' || normalized == '0' || normalized == 'no') {
          return false;
        }
      }
    }
    return null;
  }

  List<String> _candidateStoreUrls(String? configuredUrl) {
    final url = configuredUrl?.trim();
    final urls = <String>[
      if (url != null && url.isNotEmpty) url,
    ];

    if (Platform.isIOS) {
      urls.addAll(const [
        'itms-apps://apps.apple.com/ae/app/el-race-cont-operations/id6748855825',
        'https://apps.apple.com/ae/app/el-race-cont-operations/id6748855825',
      ]);
    } else {
      urls.addAll(const [
        'market://details?id=ae.elrace.mobile',
        'https://play.google.com/store/apps/details?id=ae.elrace.mobile',
      ]);
    }

    return urls;
  }
}
