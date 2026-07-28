import 'package:el_race/core/site_management/face_recognition/face_enrollment_status_service.dart';
import 'package:el_race/core/timesheet/providers/timesheet_data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enrolled map for the foreman's labor roster (one face-DB sync).
final timesheetForemanEnrollmentMapProvider =
    FutureProvider.autoDispose<Map<int, bool>>((ref) async {
  final labors = await ref.watch(timesheetForemanLaborsProvider.future);
  final service = FaceEnrollmentStatusService();
  final results = await service.checkEmployees(
    labors.map((m) => m.employeeId),
  );
  return {
    for (final entry in results.entries) entry.key: entry.value.isEnrolled,
  };
});
