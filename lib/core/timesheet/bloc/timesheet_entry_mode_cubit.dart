import 'package:flutter_bloc/flutter_bloc.dart';

/// Which home card opened the module: drives project-detail chrome and tabs.
enum TimesheetEntryMode {
  timesheet,
  siteManagement,
}

class TimesheetEntryModeCubit extends Cubit<TimesheetEntryMode> {
  TimesheetEntryModeCubit() : super(TimesheetEntryMode.timesheet);

  void setMode(TimesheetEntryMode mode) => emit(mode);
}
