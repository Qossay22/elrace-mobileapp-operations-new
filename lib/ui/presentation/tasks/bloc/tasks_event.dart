import 'dart:async';

import 'package:el_race/ui/presentation/tasks/data/task_model.dart';

sealed class TasksEvent {
  const TasksEvent();
}

final class TasksRequested extends TasksEvent {
  const TasksRequested({this.forceRefresh = false, this.completer});

  final bool forceRefresh;
  final Completer<void>? completer;
}

final class TasksRefreshRequested extends TasksEvent {
  const TasksRefreshRequested({this.completer});

  final Completer<void>? completer;
}

final class AssignableUsersRequested extends TasksEvent {
  const AssignableUsersRequested({this.completer});

  final Completer<void>? completer;
}

final class TaskCreateRequested extends TasksEvent {
  const TaskCreateRequested({
    required this.name,
    this.description,
    this.priority,
    this.userId,
    this.attachmentBase64,
    this.attachmentFilename,
    this.comment,
    required this.completer,
  });

  final String name;
  final String? description;
  final String? priority;
  final int? userId;
  final String? attachmentBase64;
  final String? attachmentFilename;
  final String? comment;
  final Completer<TaskModel?> completer;
}

final class ReportTaskCreateRequested extends TasksEvent {
  const ReportTaskCreateRequested({
    required this.name,
    this.description,
    this.priority,
    this.userId,
    required this.reportId,
    this.attachmentBase64,
    this.attachmentFilename,
    this.comment,
    required this.completer,
  });

  final String name;
  final String? description;
  final String? priority;
  final int? userId;
  final String reportId;
  final String? attachmentBase64;
  final String? attachmentFilename;
  final String? comment;
  final Completer<TaskModel?> completer;
}

final class TaskCompleteRequested extends TasksEvent {
  const TaskCompleteRequested({
    required this.taskId,
    required this.completer,
  });

  final int taskId;
  final Completer<String?> completer;
}

final class TaskReportLinkRequested extends TasksEvent {
  const TaskReportLinkRequested({
    required this.taskId,
    required this.reportId,
    required this.completer,
  });

  final int taskId;
  final String reportId;
  final Completer<String?> completer;
}

final class TaskUpdateRequested extends TasksEvent {
  const TaskUpdateRequested({
    required this.taskId,
    this.name,
    this.description,
    this.priority,
    required this.completer,
  });

  final int taskId;
  final String? name;
  final String? description;
  final String? priority;
  final Completer<String?> completer;
}

final class TaskDeleteRequested extends TasksEvent {
  const TaskDeleteRequested({
    required this.taskId,
    required this.completer,
  });

  final int taskId;
  final Completer<String?> completer;
}
