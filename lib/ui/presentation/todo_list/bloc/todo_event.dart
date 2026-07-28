import 'dart:async';

import 'package:el_race/ui/presentation/todo_list/bloc/todo_state.dart';
import 'package:el_race/ui/presentation/todo_list/data/todo_list_model.dart';
import 'package:el_race/ui/presentation/todo_list/data/todo_model.dart';
import 'package:el_race/ui/presentation/todo_list/services/team_members_api_service.dart';

sealed class TodoEvent {
  const TodoEvent();
}

final class TodoInitialized extends TodoEvent {
  const TodoInitialized({this.completer});

  final Completer<void>? completer;
}

final class TodosRequested extends TodoEvent {
  const TodosRequested({this.completer});

  final Completer<void>? completer;
}

final class TodoListsRequested extends TodoEvent {
  const TodoListsRequested({this.completer});

  final Completer<void>? completer;
}

final class TodoTeamMembersRequested extends TodoEvent {
  const TodoTeamMembersRequested({this.forceRefresh = false, this.completer});

  final bool forceRefresh;
  final Completer<void>? completer;
}

final class TodoCountsRequested extends TodoEvent {
  const TodoCountsRequested({this.completer});

  final Completer<void>? completer;
}

final class TodoFilterChanged extends TodoEvent {
  const TodoFilterChanged({
    required this.filter,
    this.listId,
    this.completer,
  });

  final TodoFilter filter;
  final String? listId;
  final Completer<void>? completer;
}

final class TodoSearchChanged extends TodoEvent {
  const TodoSearchChanged({required this.query, this.completer});

  final String query;
  final Completer<void>? completer;
}

final class TodoSearchCleared extends TodoEvent {
  const TodoSearchCleared();
}

final class TodoAddRequested extends TodoEvent {
  const TodoAddRequested({
    required this.title,
    this.description,
    this.isImportant = false,
    this.isMyDay = false,
    this.dueDate,
    this.assignedTo,
    this.assignedToName,
    this.listId,
    required this.completer,
  });

  final String title;
  final String? description;
  final bool isImportant;
  final bool isMyDay;
  final DateTime? dueDate;
  final String? assignedTo;
  final String? assignedToName;
  final String? listId;
  final Completer<TodoModel?> completer;
}

final class TodoUpdateRequested extends TodoEvent {
  const TodoUpdateRequested({required this.todo, required this.completer});

  final TodoModel todo;
  final Completer<bool> completer;
}

final class TodoDeleteRequested extends TodoEvent {
  const TodoDeleteRequested({required this.todo, required this.completer});

  final TodoModel todo;
  final Completer<bool> completer;
}

final class TodoReportTaskCreateRequested extends TodoEvent {
  const TodoReportTaskCreateRequested({
    required this.reportId,
    required this.reportName,
    this.description,
    this.isImportant = false,
    this.dueDate,
    required this.completer,
  });

  final String reportId;
  final String reportName;
  final String? description;
  final bool isImportant;
  final DateTime? dueDate;
  final Completer<TodoModel?> completer;
}

final class TodoCompleteToggled extends TodoEvent {
  const TodoCompleteToggled({required this.todo, this.completer});

  final TodoModel todo;
  final Completer<void>? completer;
}

final class TodoImportantToggled extends TodoEvent {
  const TodoImportantToggled({required this.todo, this.completer});

  final TodoModel todo;
  final Completer<void>? completer;
}

final class TodoMyDayToggled extends TodoEvent {
  const TodoMyDayToggled({required this.todo, this.completer});

  final TodoModel todo;
  final Completer<void>? completer;
}

final class TodoReorderRequested extends TodoEvent {
  const TodoReorderRequested({
    required this.oldIndex,
    required this.newIndex,
    this.completer,
  });

  final int oldIndex;
  final int newIndex;
  final Completer<void>? completer;
}

final class TodoListAddRequested extends TodoEvent {
  const TodoListAddRequested({
    required this.name,
    this.iconName,
    this.color,
    required this.completer,
  });

  final String name;
  final String? iconName;
  final String? color;
  final Completer<TodoListModel?> completer;
}

final class TodoListUpdateRequested extends TodoEvent {
  const TodoListUpdateRequested({required this.list, required this.completer});

  final TodoListModel list;
  final Completer<bool> completer;
}

final class TodoListDeleteRequested extends TodoEvent {
  const TodoListDeleteRequested({
    required this.firebaseId,
    required this.completer,
  });

  final String firebaseId;
  final Completer<bool> completer;
}

final class TodoErrorCleared extends TodoEvent {
  const TodoErrorCleared();
}

final class TodoStreamChanged extends TodoEvent {
  const TodoStreamChanged(this.todos);

  final List<TodoModel> todos;
}

final class TodoListsStreamChanged extends TodoEvent {
  const TodoListsStreamChanged(this.lists);

  final List<TodoListModel> lists;
}

final class TodoTeamMembersLoaded extends TodoEvent {
  const TodoTeamMembersLoaded(this.members);

  final List<TeamMember> members;
}
