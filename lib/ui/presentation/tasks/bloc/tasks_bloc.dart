import 'dart:async';

import 'package:el_race/core/logging/app_logger.dart';
import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/data/services/task_notification_service.dart';
import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:el_race/ui/presentation/tasks/bloc/tasks_event.dart';
import 'package:el_race/ui/presentation/tasks/bloc/tasks_state.dart';
import 'package:el_race/ui/presentation/tasks/data/assignable_user_model.dart';
import 'package:el_race/ui/presentation/tasks/data/task_model.dart';
import 'package:el_race/ui/presentation/tasks/data/tasks_api_service.dart';
import 'package:el_race/ui/presentation/tasks/data/tasks_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc(this._repository) : super(const TasksState()) {
    on<TasksRequested>(_onTasksRequested);
    on<TasksRefreshRequested>(_onTasksRefreshRequested);
    on<AssignableUsersRequested>(_onAssignableUsersRequested);
    on<TaskCreateRequested>(_onTaskCreateRequested);
    on<ReportTaskCreateRequested>(_onReportTaskCreateRequested);
    on<TaskCompleteRequested>(_onTaskCompleteRequested);
    on<TaskReportLinkRequested>(_onTaskReportLinkRequested);
    on<TaskUpdateRequested>(_onTaskUpdateRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
  }

  final TasksRepository _repository;

  TasksStatus get status => state.status;
  List<TaskModel> get tasks => state.tasks;
  String? get errorMessage => state.errorMessage;
  List<AssignableUser> get assignableUsers => state.assignableUsers;
  bool get isLoadingUsers => state.isLoadingUsers;
  bool get usersLoaded => state.usersLoaded;
  bool get isCreating => state.isCreating;
  Set<int> get completingTaskIds => state.completingTaskIds;
  Set<int> get linkingTaskIds => state.linkingTaskIds;
  Set<int> get updatingTaskIds => state.updatingTaskIds;
  Set<int> get deletingTaskIds => state.deletingTaskIds;

  TicketsWidgetRecord get ticketsWidgetRecord {
    final openTickets = state.tasks.where((task) => !task.isCompleted).toList();
    final highPriority = openTickets
        .where((task) => task.priority == '2' || task.priority == '3')
        .length;
    final totalOpen = openTickets.length;

    String trendMessage;
    String trendColor;
    if (totalOpen == 0) {
      trendMessage = '';
      trendColor = 'neutral';
    } else if (highPriority == 0) {
      trendMessage = 'All on track';
      trendColor = 'green';
    } else if (highPriority == 1) {
      trendMessage = '1 high priority';
      trendColor = 'red';
    } else {
      trendMessage = '$highPriority high priority';
      trendColor = 'red';
    }

    return TicketsWidgetRecord(
      totalOpen: totalOpen,
      highPriorityCount: highPriority,
      trendMessage: trendMessage,
      trendColor: trendColor,
    );
  }

  Future<void> loadTasks({bool forceRefresh = false}) {
    final completer = Completer<void>();
    add(TasksRequested(forceRefresh: forceRefresh, completer: completer));
    return completer.future;
  }

  Future<void> refreshTasks() {
    final completer = Completer<void>();
    add(TasksRefreshRequested(completer: completer));
    return completer.future;
  }

  Future<void> loadAssignableUsers() {
    final completer = Completer<void>();
    add(AssignableUsersRequested(completer: completer));
    return completer.future;
  }

  Future<TaskModel?> createTask({
    required String name,
    String? description,
    String? priority,
    int? userId,
    String? attachmentBase64,
    String? attachmentFilename,
    String? comment,
  }) {
    final completer = Completer<TaskModel?>();
    add(
      TaskCreateRequested(
        name: name,
        description: description,
        priority: priority,
        userId: userId,
        attachmentBase64: attachmentBase64,
        attachmentFilename: attachmentFilename,
        comment: comment,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<TaskModel?> createTaskForReport({
    required String name,
    String? description,
    String? priority,
    int? userId,
    required String reportId,
    String? attachmentBase64,
    String? attachmentFilename,
    String? comment,
  }) {
    final completer = Completer<TaskModel?>();
    add(
      ReportTaskCreateRequested(
        name: name,
        description: description,
        priority: priority,
        userId: userId,
        reportId: reportId,
        attachmentBase64: attachmentBase64,
        attachmentFilename: attachmentFilename,
        comment: comment,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<String?> completeTask(int taskId) {
    final completer = Completer<String?>();
    add(TaskCompleteRequested(taskId: taskId, completer: completer));
    return completer.future;
  }

  Future<String?> linkReport({
    required int taskId,
    required String reportId,
  }) {
    final completer = Completer<String?>();
    add(
      TaskReportLinkRequested(
        taskId: taskId,
        reportId: reportId,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<String?> updateTask({
    required int taskId,
    String? name,
    String? description,
    String? priority,
  }) {
    final completer = Completer<String?>();
    add(
      TaskUpdateRequested(
        taskId: taskId,
        name: name,
        description: description,
        priority: priority,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<String?> deleteTask(int taskId) {
    final completer = Completer<String?>();
    add(TaskDeleteRequested(taskId: taskId, completer: completer));
    return completer.future;
  }

  Future<void> _onTasksRequested(
    TasksRequested event,
    Emitter<TasksState> emit,
  ) async {
    await _loadTasks(emit);
    event.completer?.complete();
  }

  Future<void> _onTasksRefreshRequested(
    TasksRefreshRequested event,
    Emitter<TasksState> emit,
  ) async {
    await _loadTasks(emit);
    event.completer?.complete();
  }

  Future<void> _onAssignableUsersRequested(
    AssignableUsersRequested event,
    Emitter<TasksState> emit,
  ) async {
    await _loadAssignableUsers(emit);
    event.completer?.complete();
  }

  Future<void> _loadTasks(Emitter<TasksState> emit) async {
    if (state.status == TasksStatus.loading) return;
    emit(state.copyWith(status: TasksStatus.loading, errorMessage: null));

    try {
      final response = await _repository.getUserTasks();
      emit(
        state.copyWith(
          tasks: response,
          status: response.isEmpty ? TasksStatus.empty : TasksStatus.loaded,
        ),
      );
    } on TasksUnauthorizedException {
      emit(
        state.copyWith(
          errorMessage: 'Your session has expired. Please sign in again.',
          status: TasksStatus.error,
        ),
      );
    } on TasksApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message, status: TasksStatus.error));
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Unexpected error. Please try again.',
          status: TasksStatus.error,
        ),
      );
    }
  }

  Future<void> _loadAssignableUsers(Emitter<TasksState> emit) async {
    if (state.usersLoaded || state.isLoadingUsers) return;
    emit(state.copyWith(errorMessage: null, isLoadingUsers: true));
    try {
      final users = await _repository.getAssignableUsers();
      emit(
        state.copyWith(
          assignableUsers: users,
          usersLoaded: true,
          isLoadingUsers: false,
        ),
      );
    } on TasksApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message, isLoadingUsers: false));
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Unexpected error. Please try again.',
          isLoadingUsers: false,
        ),
      );
    }
  }

  Future<void> _onTaskCreateRequested(
    TaskCreateRequested event,
    Emitter<TasksState> emit,
  ) async {
    if (state.isCreating) {
      event.completer.complete(null);
      return;
    }
    emit(state.copyWith(errorMessage: null, isCreating: true));
    try {
      final created = await _repository.createTask(
        name: event.name,
        description: event.description,
        priority: event.priority,
        userId: event.userId,
        attachmentBase64: event.attachmentBase64,
        attachmentFilename: event.attachmentFilename,
        comment: event.comment ?? event.description,
      );

      var taskWithData = created;
      if (created.createdAt == null) {
        taskWithData = taskWithData.copyWith(createdAt: DateTime.now());
      }
      if (created.priority == null && event.priority != null) {
        taskWithData = taskWithData.copyWith(priority: event.priority);
      }

      emit(
        state.copyWith(
          tasks: [taskWithData, ...state.tasks],
          status: TasksStatus.loaded,
        ),
      );

      await _showNewTaskNotification(taskWithData, event.name);
      await Future.delayed(const Duration(milliseconds: 1500));
      await _loadTasks(emit);

      event.completer.complete(taskWithData);
    } on TasksApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      event.completer.complete(null);
    } finally {
      emit(state.copyWith(isCreating: false));
    }
  }

  Future<void> _onReportTaskCreateRequested(
    ReportTaskCreateRequested event,
    Emitter<TasksState> emit,
  ) async {
    if (state.isCreating) {
      event.completer.complete(null);
      return;
    }
    emit(state.copyWith(errorMessage: null, isCreating: true));

    try {
      var resolvedUserId = event.userId;
      if (resolvedUserId == null) {
        final login = SharedPref.getLoginDataOrNull();
        resolvedUserId = login?.result?.data?.uid;
      }

      var created = await _repository.createTask(
        name: event.name,
        description: event.description,
        priority: event.priority,
        userId: resolvedUserId,
        attachmentBase64: event.attachmentBase64,
        attachmentFilename: event.attachmentFilename,
        comment: event.comment ?? event.description,
      );

      if (created.createdAt == null) {
        created = created.copyWith(createdAt: DateTime.now());
      }
      if (created.priority == null && event.priority != null) {
        created = created.copyWith(priority: event.priority);
      }

      emit(
        state.copyWith(
          tasks: [created, ...state.tasks],
          status: TasksStatus.loaded,
        ),
      );

      await _showNewTaskNotification(created, event.name);

      if (created.id != null && event.reportId.isNotEmpty) {
        await _repository.linkReportToTask(
          taskId: created.id!,
          reportId: event.reportId,
        );
      }

      await _loadTasks(emit);
      event.completer.complete(created);
    } on TasksApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      event.completer.complete(null);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to create task: $e'));
      event.completer.complete(null);
    } finally {
      emit(state.copyWith(isCreating: false));
    }
  }

  Future<void> _onTaskCompleteRequested(
    TaskCompleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(
      state.copyWith(
        errorMessage: null,
        completingTaskIds: {...state.completingTaskIds, event.taskId},
      ),
    );
    try {
      final message = await _repository.submitTask(taskId: event.taskId);
      final taskName = state.tasks
              .where((t) => t.id == event.taskId)
              .map((t) => t.name)
              .firstOrNull ??
          'Task #${event.taskId}';

      try {
        await TaskNotificationService().showTaskCompletedNotification(
          taskId: '${event.taskId}',
          taskTitle: taskName,
          isFirebaseTask: false,
        );
      } catch (e) {
        AppLogger.warning(
          'TasksBloc: failed to show task completed notification',
          error: e,
          data: {'task_id': event.taskId},
        );
      }

      await _loadTasks(emit);
      event.completer.complete(message);
    } on TasksApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      event.completer.complete(null);
    } finally {
      emit(
        state.copyWith(
          completingTaskIds: {...state.completingTaskIds}..remove(event.taskId),
        ),
      );
    }
  }

  Future<void> _onTaskReportLinkRequested(
    TaskReportLinkRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(
      state.copyWith(
        errorMessage: null,
        linkingTaskIds: {...state.linkingTaskIds, event.taskId},
      ),
    );
    try {
      final message = await _repository.linkReportToTask(
        taskId: event.taskId,
        reportId: event.reportId,
      );
      await _loadTasks(emit);
      event.completer.complete(message);
    } on TasksApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      event.completer.complete(null);
    } finally {
      emit(
        state.copyWith(
          linkingTaskIds: {...state.linkingTaskIds}..remove(event.taskId),
        ),
      );
    }
  }

  Future<void> _onTaskUpdateRequested(
    TaskUpdateRequested event,
    Emitter<TasksState> emit,
  ) async {
    if ((event.name == null || event.name!.trim().isEmpty) &&
        (event.description == null || event.description!.trim().isEmpty) &&
        (event.priority == null || event.priority!.trim().isEmpty)) {
      emit(
          state.copyWith(errorMessage: 'Please change a field before saving.'));
      event.completer.complete(null);
      return;
    }

    emit(
      state.copyWith(
        errorMessage: null,
        updatingTaskIds: {...state.updatingTaskIds, event.taskId},
      ),
    );

    try {
      final message = await _repository.updateTask(
        taskId: event.taskId,
        name: event.name?.trim(),
        description: event.description?.trim(),
        priority: event.priority?.trim(),
      );

      await _loadTasks(emit);
      event.completer.complete(message);
    } on TasksApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      event.completer.complete(null);
    } finally {
      emit(
        state.copyWith(
          updatingTaskIds: {...state.updatingTaskIds}..remove(event.taskId),
        ),
      );
    }
  }

  Future<void> _onTaskDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(
      state.copyWith(
        errorMessage: null,
        deletingTaskIds: {...state.deletingTaskIds, event.taskId},
      ),
    );

    try {
      final message = await _repository.deleteTask(taskId: event.taskId);
      final nextTasks = state.tasks.where((t) => t.id != event.taskId).toList();
      emit(
        state.copyWith(
          tasks: nextTasks,
          status: nextTasks.isEmpty ? TasksStatus.empty : state.status,
        ),
      );

      await _loadTasks(emit);
      event.completer.complete(message);
    } on TasksApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      event.completer.complete(null);
    } finally {
      emit(
        state.copyWith(
          deletingTaskIds: {...state.deletingTaskIds}..remove(event.taskId),
        ),
      );
    }
  }

  Future<void> _showNewTaskNotification(TaskModel task, String title) async {
    try {
      final currentUserName =
          SharedPref.getLoginData().result?.data?.name ?? '';
      await TaskNotificationService().showNewTaskNotification(
        taskId: '${task.id ?? 0}',
        taskTitle: title,
        assignedBy: currentUserName,
        isFirebaseTask: false,
      );
    } catch (e) {
      AppLogger.warning(
        'TasksBloc: failed to show new task notification',
        error: e,
        data: {'task_id': task.id, 'title': title},
      );
    }
  }
}
