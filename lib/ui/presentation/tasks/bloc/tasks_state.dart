import 'package:el_race/ui/presentation/tasks/data/assignable_user_model.dart';
import 'package:el_race/ui/presentation/tasks/data/task_model.dart';

enum TasksStatus { initial, loading, loaded, empty, error }

class TasksState {
  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.errorMessage,
    this.assignableUsers = const [],
    this.isLoadingUsers = false,
    this.usersLoaded = false,
    this.isCreating = false,
    this.completingTaskIds = const {},
    this.linkingTaskIds = const {},
    this.updatingTaskIds = const {},
    this.deletingTaskIds = const {},
  });

  final TasksStatus status;
  final List<TaskModel> tasks;
  final String? errorMessage;
  final List<AssignableUser> assignableUsers;
  final bool isLoadingUsers;
  final bool usersLoaded;
  final bool isCreating;
  final Set<int> completingTaskIds;
  final Set<int> linkingTaskIds;
  final Set<int> updatingTaskIds;
  final Set<int> deletingTaskIds;

  TasksState copyWith({
    TasksStatus? status,
    List<TaskModel>? tasks,
    Object? errorMessage = _sentinel,
    List<AssignableUser>? assignableUsers,
    bool? isLoadingUsers,
    bool? usersLoaded,
    bool? isCreating,
    Set<int>? completingTaskIds,
    Set<int>? linkingTaskIds,
    Set<int>? updatingTaskIds,
    Set<int>? deletingTaskIds,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      assignableUsers: assignableUsers ?? this.assignableUsers,
      isLoadingUsers: isLoadingUsers ?? this.isLoadingUsers,
      usersLoaded: usersLoaded ?? this.usersLoaded,
      isCreating: isCreating ?? this.isCreating,
      completingTaskIds: completingTaskIds ?? this.completingTaskIds,
      linkingTaskIds: linkingTaskIds ?? this.linkingTaskIds,
      updatingTaskIds: updatingTaskIds ?? this.updatingTaskIds,
      deletingTaskIds: deletingTaskIds ?? this.deletingTaskIds,
    );
  }

  static const Object _sentinel = Object();
}
