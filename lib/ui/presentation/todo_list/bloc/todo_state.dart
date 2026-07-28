import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:el_race/ui/presentation/todo_list/data/todo_list_model.dart';
import 'package:el_race/ui/presentation/todo_list/data/todo_model.dart';
import 'package:el_race/ui/presentation/todo_list/services/team_members_api_service.dart';

enum TodoFilter {
  all,
  myDay,
  important,
  planned,
  assignedToMe,
  tasks,
  customList,
}

class TodoState {
  const TodoState({
    this.todos = const [],
    this.filteredTodos = const [],
    this.todoLists = const [],
    this.teamMembers = const [],
    this.currentFilter = TodoFilter.all,
    this.currentListId,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.totalCount = 0,
    this.myDayCount = 0,
    this.importantCount = 0,
    this.plannedCount = 0,
    this.assignedToMeCount = 0,
  });

  final List<TodoModel> todos;
  final List<TodoModel> filteredTodos;
  final List<TodoListModel> todoLists;
  final List<TeamMember> teamMembers;
  final TodoFilter currentFilter;
  final String? currentListId;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final int totalCount;
  final int myDayCount;
  final int importantCount;
  final int plannedCount;
  final int assignedToMeCount;

  TaskManagementWidgetRecord get taskManagementRecord {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var open = 0;
    var inProgress = 0;
    var done = 0;
    var dueToday = 0;

    for (final todo in todos) {
      if (todo.isCompleted) {
        done++;
        continue;
      }

      final progress = todo.progress;
      if (progress > 0 && progress < 1) {
        inProgress++;
      } else {
        open++;
      }

      final due = todo.dueDate;
      if (due != null) {
        final dueDay = DateTime(due.year, due.month, due.day);
        if (dueDay == today) dueToday++;
      }
    }

    return TaskManagementWidgetRecord(
      openCount: open,
      inProgressCount: inProgress,
      doneCount: done,
      dueTodayCount: dueToday,
      dueTodayMessage: _dueTodayMessage(dueToday),
    );
  }

  static String _dueTodayMessage(int count) {
    if (count <= 0) return 'No tasks due today';
    if (count == 1) return '1 task due today';
    return '$count tasks due today';
  }

  TodoState copyWith({
    List<TodoModel>? todos,
    List<TodoModel>? filteredTodos,
    List<TodoListModel>? todoLists,
    List<TeamMember>? teamMembers,
    TodoFilter? currentFilter,
    Object? currentListId = _sentinel,
    String? searchQuery,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    int? totalCount,
    int? myDayCount,
    int? importantCount,
    int? plannedCount,
    int? assignedToMeCount,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      todoLists: todoLists ?? this.todoLists,
      teamMembers: teamMembers ?? this.teamMembers,
      currentFilter: currentFilter ?? this.currentFilter,
      currentListId: identical(currentListId, _sentinel)
          ? this.currentListId
          : currentListId as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      totalCount: totalCount ?? this.totalCount,
      myDayCount: myDayCount ?? this.myDayCount,
      importantCount: importantCount ?? this.importantCount,
      plannedCount: plannedCount ?? this.plannedCount,
      assignedToMeCount: assignedToMeCount ?? this.assignedToMeCount,
    );
  }

  static const Object _sentinel = Object();
}
