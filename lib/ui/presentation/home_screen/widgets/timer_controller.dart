import 'dart:async';

import 'package:el_race/core/utils/shared_pref.dart';

/// Global timer service for the check-in/check-out flow.
///
/// The working-hours countdown is global across projects. Project selection is
/// only contextual and does not create a separate timer.
class TimerController {
  TimerController._();

  static final TimerController instance = TimerController._();

  Duration timeLeft = const Duration(hours: 8);
  bool isTimerRunning = false;

  Timer? _timer;
  DateTime? _checkInTime;
  Duration _initialRemaining = const Duration(hours: 8);

  Future<void> ensureLoaded() => _loadState();

  Future<void> _loadState() async {
    final isCheckedIn = SharedPref().getPreferenceBoolean('isCheckedIn');
    final checkInMillis = SharedPref().getPreferenceInt('checkInTime');
    final savedTimeLeftMillis = SharedPref().getPreferenceInt('timeLeft');

    if (isCheckedIn && checkInMillis > 0) {
      _checkInTime = DateTime.fromMillisecondsSinceEpoch(checkInMillis);
      final elapsed = DateTime.now().difference(_checkInTime!);
      _initialRemaining = const Duration(hours: 8) - elapsed;

      if (_initialRemaining.inSeconds <= 0) {
        _initialRemaining = Duration.zero;
        timeLeft = Duration.zero;
        isTimerRunning = false;
      } else {
        timeLeft = _initialRemaining;
        isTimerRunning = true;
        _startCountdown();
      }
      return;
    }

    if (savedTimeLeftMillis > 0) {
      _initialRemaining = Duration(milliseconds: savedTimeLeftMillis);
    } else {
      _initialRemaining = const Duration(hours: 8);
    }
    timeLeft = _initialRemaining;
    isTimerRunning = false;
  }

  Future<void> startTimer() async {
    _checkInTime = DateTime.now();
    _initialRemaining = const Duration(hours: 8);

    await SharedPref()
        .setPreferenceInt('checkInTime', _checkInTime!.millisecondsSinceEpoch);
    await SharedPref().setPreferencesBoolean('isCheckedIn', true);

    isTimerRunning = true;
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();

    if (_checkInTime == null) {
      return;
    }

    final startTime = _checkInTime!;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final elapsed = DateTime.now().difference(startTime);
      final remaining = const Duration(hours: 8) - elapsed;

      if (remaining.inSeconds <= 0) {
        timeLeft = Duration.zero;
        isTimerRunning = false;
        _timer?.cancel();
        _timer = null;
      } else {
        timeLeft = remaining;
        if (remaining.inSeconds % 60 == 0) {
          await SharedPref()
              .setPreferenceInt('timeLeft', remaining.inMilliseconds);
        }
      }
    });
  }

  Future<void> stopTimer() async {
    _timer?.cancel();
    _timer = null;
    isTimerRunning = false;

    if (_checkInTime == null) {
      SharedPref().removePreference('checkInTime');
      SharedPref().removePreference('isCheckedIn');
      SharedPref().removePreference('timeLeft');
      return;
    }

    final elapsed = DateTime.now().difference(_checkInTime!);
    final updatedRemaining = const Duration(hours: 8) - elapsed;

    await SharedPref().setPreferencesBoolean('isCheckedIn', false);
    await SharedPref().removePreference('checkInTime');

    if (updatedRemaining.inSeconds > 0) {
      await SharedPref()
          .setPreferenceInt('timeLeft', updatedRemaining.inMilliseconds);
      _initialRemaining = updatedRemaining;
      timeLeft = updatedRemaining;
    } else {
      await SharedPref().setPreferenceInt('timeLeft', 0);
      _initialRemaining = Duration.zero;
      timeLeft = Duration.zero;
    }

    _checkInTime = null;
  }

  Future<void> reloadState() => _loadState();

  void dispose() {
    _timer?.cancel();
  }
}
