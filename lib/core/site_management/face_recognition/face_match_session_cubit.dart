import 'package:el_race/core/site_management/face_recognition/face_match_logger.dart';
import 'package:el_race/core/site_management/face_recognition/face_match_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FaceMatchSessionCubit extends Cubit<FaceMatchSessionRecord?> {
  FaceMatchSessionCubit() : super(null);

  void record(FaceMatchSessionRecord record) {
    emit(record);
    debugPrint(
      'FaceMatchSession: ${record.outcome} '
      'score=${record.bestScore.toStringAsFixed(4)} '
      'emp=${record.employeeId} followUp=${record.followUp}',
    );
  }

  void markConfirmed() {
    final s = state;
    if (s == null) return;
    emit(s.copyWith(followUp: FaceForemanFollowUp.confirmed));
    FaceMatchLogger.logForemanFollowUp(
      followUp: FaceForemanFollowUp.confirmed,
      session: s,
    );
    debugPrint('FaceMatchSession: foreman confirmed emp=${s.employeeId}');
  }

  void markRejected() {
    final s = state;
    if (s == null) return;
    emit(s.copyWith(followUp: FaceForemanFollowUp.rejected));
    FaceMatchLogger.logForemanFollowUp(
      followUp: FaceForemanFollowUp.rejected,
      session: s,
    );
    debugPrint('FaceMatchSession: foreman rejected match emp=${s.employeeId}');
  }

  void markManualPick() {
    final s = state;
    if (s == null) {
      debugPrint('FaceMatchSession: foreman manual pick (no prior match)');
      return;
    }
    emit(s.copyWith(followUp: FaceForemanFollowUp.manualPick));
    FaceMatchLogger.logForemanFollowUp(
      followUp: FaceForemanFollowUp.manualPick,
      session: s,
    );
    debugPrint('FaceMatchSession: foreman manual pick (was ${s.outcome})');
  }

  void clear() => emit(null);
}
