import 'package:el_race/core/timesheet/bloc/timesheet_entry_mode_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Sets [TimesheetEntryModeCubit] for the whole module navigation stack.
class TimesheetEntryModeScope extends StatefulWidget {
  const TimesheetEntryModeScope({
    super.key,
    required this.mode,
    required this.child,
  });

  final TimesheetEntryMode mode;
  final Widget child;

  @override
  State<TimesheetEntryModeScope> createState() =>
      _TimesheetEntryModeScopeState();
}

class _TimesheetEntryModeScopeState extends State<TimesheetEntryModeScope> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TimesheetEntryModeCubit>().setMode(widget.mode);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
