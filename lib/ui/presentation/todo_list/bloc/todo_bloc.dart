import 'dart:async';

import 'package:el_race/ui/presentation/signin/data/model.dart';
import 'package:el_race/ui/presentation/todo_list/bloc/todo_event.dart';
import 'package:el_race/ui/presentation/todo_list/bloc/todo_state.dart';
import 'package:el_race/ui/presentation/todo_list/data/todo_list_model.dart';
import 'package:el_race/ui/presentation/todo_list/data/todo_model.dart';
import 'package:el_race/ui/presentation/todo_list/services/team_members_api_service.dart';
import 'package:el_race/ui/presentation/todo_list/services/todo_firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc({
    TodoFirebaseService? firebaseService,
    TeamMembersApiService? membersService,
  })  : _firebaseService = firebaseService ?? TodoFirebaseService.instance,
        _membersService = membersService ?? TeamMembersApiService.instance,
        super(const TodoState()) {
    on<TodoInitialized>(_onInitialized);
    on<TodosRequested>(_onTodosRequested);
    on<TodoListsRequested>(_onTodoListsRequested);
    on<TodoTeamMembersRequested>(_onTeamMembersRequested);
    on<TodoCountsRequested>(_onCountsRequested);
    on<TodoFilterChanged>(_onFilterChanged);
    on<TodoSearchChanged>(_onSearchChanged);
    on<TodoSearchCleared>(_onSearchCleared);
    on<TodoAddRequested>(_onTodoAddRequested);
    on<TodoUpdateRequested>(_onTodoUpdateRequested);
    on<TodoDeleteRequested>(_onTodoDeleteRequested);
    on<TodoReportTaskCreateRequested>(_onReportTaskCreateRequested);
    on<TodoCompleteToggled>(_onCompleteToggled);
    on<TodoImportantToggled>(_onImportantToggled);
    on<TodoMyDayToggled>(_onMyDayToggled);
    on<TodoReorderRequested>(_onReorderRequested);
    on<TodoListAddRequested>(_onListAddRequested);
    on<TodoListUpdateRequested>(_onListUpdateRequested);
    on<TodoListDeleteRequested>(_onListDeleteRequested);
    on<TodoErrorCleared>(_onErrorCleared);
    on<TodoStreamChanged>(_onTodoStreamChanged);
    on<TodoListsStreamChanged>(_onTodoListsStreamChanged);
    on<TodoTeamMembersLoaded>(_onTeamMembersLoaded);
  }

  final TodoFirebaseService _firebaseService;
  final TeamMembersApiService _membersService;
  StreamSubscription? _todosSubscription;
  StreamSubscription? _listsSubscription;

  List<TodoModel> get todos => state.filteredTodos;
  List<TodoListModel> get todoLists => state.todoLists;
  List<TeamMember> get teamMembers => state.teamMembers;
  TodoFilter get currentFilter => state.currentFilter;
  String? get currentListId => state.currentListId;
  String get searchQuery => state.searchQuery;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  int get totalCount => state.totalCount;
  int get myDayCount => state.myDayCount;
  int get importantCount => state.importantCount;
  int get plannedCount => state.plannedCount;
  int get assignedToMeCount => state.assignedToMeCount;
  TaskManagementWidgetRecord get taskManagementRecord =>
      state.taskManagementRecord;

  Future<void> initialize() {
    final completer = Completer<void>();
    add(TodoInitialized(completer: completer));
    return completer.future;
  }

  Future<void> loadTodos() {
    final completer = Completer<void>();
    add(TodosRequested(completer: completer));
    return completer.future;
  }

  Future<void> loadTodoLists() {
    final completer = Completer<void>();
    add(TodoListsRequested(completer: completer));
    return completer.future;
  }

  Future<void> loadTeamMembers({bool forceRefresh = false}) {
    final completer = Completer<void>();
    add(
      TodoTeamMembersRequested(
        forceRefresh: forceRefresh,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<List<TeamMember>> searchTeamMembers(String query) {
    return _membersService.searchMembers(query);
  }

  Future<void> refreshCounts() {
    final completer = Completer<void>();
    add(TodoCountsRequested(completer: completer));
    return completer.future;
  }

  Future<void> setFilter(TodoFilter filter, {String? listId}) {
    final completer = Completer<void>();
    add(TodoFilterChanged(
        filter: filter, listId: listId, completer: completer));
    return completer.future;
  }

  Future<void> search(String query) {
    final completer = Completer<void>();
    add(TodoSearchChanged(query: query, completer: completer));
    return completer.future;
  }

  void clearSearch() {
    add(const TodoSearchCleared());
  }

  Future<TodoModel?> addTodo({
    required String title,
    String? description,
    bool isImportant = false,
    bool isMyDay = false,
    DateTime? dueDate,
    String? assignedTo,
    String? assignedToName,
    String? listId,
  }) {
    final completer = Completer<TodoModel?>();
    add(
      TodoAddRequested(
        title: title,
        description: description,
        isImportant: isImportant,
        isMyDay: isMyDay,
        dueDate: dueDate,
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        listId: listId,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<bool> updateTodo(TodoModel todo) {
    final completer = Completer<bool>();
    add(TodoUpdateRequested(todo: todo, completer: completer));
    return completer.future;
  }

  Future<bool> deleteTodo(TodoModel todo) {
    final completer = Completer<bool>();
    add(TodoDeleteRequested(todo: todo, completer: completer));
    return completer.future;
  }

  Future<List<TodoModel>> getTodosByReportId(String reportId) {
    return _firebaseService.getTodosByReportId(reportId).catchError((e) {
      debugPrint('Error getting todos by report: $e');
      return <TodoModel>[];
    });
  }

  Future<int> getTasksCountByReportId(String reportId) {
    return _firebaseService.getTasksCountByReportId(reportId).catchError((e) {
      debugPrint('Error getting tasks count: $e');
      return 0;
    });
  }

  Future<TodoModel?> createTaskFromReport({
    required String reportId,
    required String reportName,
    String? description,
    bool isImportant = false,
    DateTime? dueDate,
  }) {
    final completer = Completer<TodoModel?>();
    add(
      TodoReportTaskCreateRequested(
        reportId: reportId,
        reportName: reportName,
        description: description,
        isImportant: isImportant,
        dueDate: dueDate,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<void> toggleComplete(TodoModel todo) {
    final completer = Completer<void>();
    add(TodoCompleteToggled(todo: todo, completer: completer));
    return completer.future;
  }

  Future<void> toggleImportant(TodoModel todo) {
    final completer = Completer<void>();
    add(TodoImportantToggled(todo: todo, completer: completer));
    return completer.future;
  }

  Future<void> toggleMyDay(TodoModel todo) {
    final completer = Completer<void>();
    add(TodoMyDayToggled(todo: todo, completer: completer));
    return completer.future;
  }

  Future<void> reorderTodos(int oldIndex, int newIndex) {
    final completer = Completer<void>();
    add(
      TodoReorderRequested(
        oldIndex: oldIndex,
        newIndex: newIndex,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<TodoListModel?> addTodoList({
    required String name,
    String? iconName,
    String? color,
  }) {
    final completer = Completer<TodoListModel?>();
    add(
      TodoListAddRequested(
        name: name,
        iconName: iconName,
        color: color,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<bool> updateTodoList(TodoListModel list) {
    final completer = Completer<bool>();
    add(TodoListUpdateRequested(list: list, completer: completer));
    return completer.future;
  }

  Future<bool> deleteTodoList(String firebaseId) {
    final completer = Completer<bool>();
    add(TodoListDeleteRequested(firebaseId: firebaseId, completer: completer));
    return completer.future;
  }

  Future<int> getTodoCountForList(String listId) {
    return _firebaseService.getTodoCountByListId(listId);
  }

  void clearError() {
    add(const TodoErrorCleared());
  }

  Future<void> _onInitialized(
    TodoInitialized event,
    Emitter<TodoState> emit,
  ) async {
    await _loadTodos(emit);
    await _loadTodoLists(emit);
    await _loadTeamMembers(emit);
    await _refreshCounts(emit);
    _setupStreams();
    event.completer?.complete();
  }

  Future<void> _onTodosRequested(
    TodosRequested event,
    Emitter<TodoState> emit,
  ) async {
    await _loadTodos(emit);
    event.completer?.complete();
  }

  Future<void> _onTodoListsRequested(
    TodoListsRequested event,
    Emitter<TodoState> emit,
  ) async {
    await _loadTodoLists(emit);
    event.completer?.complete();
  }

  Future<void> _onTeamMembersRequested(
    TodoTeamMembersRequested event,
    Emitter<TodoState> emit,
  ) async {
    await _loadTeamMembers(emit, forceRefresh: event.forceRefresh);
    event.completer?.complete();
  }

  Future<void> _onCountsRequested(
    TodoCountsRequested event,
    Emitter<TodoState> emit,
  ) async {
    await _refreshCounts(emit);
    event.completer?.complete();
  }

  Future<void> _loadTodos(Emitter<TodoState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final todos = await _firebaseService.getAllTodos();
      emit(
        state.copyWith(
          todos: todos,
          filteredTodos: _applyFilter(todos, state.searchQuery),
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to load todos: $e',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _loadTodoLists(Emitter<TodoState> emit) async {
    try {
      final lists = await _firebaseService.getAllTodoLists();
      emit(state.copyWith(todoLists: lists));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load lists: $e'));
    }
  }

  Future<void> _loadTeamMembers(
    Emitter<TodoState> emit, {
    bool forceRefresh = false,
  }) async {
    try {
      final members =
          await _membersService.getTeamMembers(forceRefresh: forceRefresh);
      emit(state.copyWith(teamMembers: members));
    } catch (e) {
      debugPrint('Error loading team members: $e');
    }
  }

  Future<void> _refreshCounts(Emitter<TodoState> emit) async {
    try {
      final totalCount = await _firebaseService.getTodosCount();
      final myDayCount = await _firebaseService.getMyDayCount();
      final importantCount = await _firebaseService.getImportantCount();
      final plannedCount = await _firebaseService.getPlannedCount();
      final assignedTodos = await _firebaseService.getAssignedToMeTodos(null);

      emit(
        state.copyWith(
          totalCount: totalCount,
          myDayCount: myDayCount,
          importantCount: importantCount,
          plannedCount: plannedCount,
          assignedToMeCount: assignedTodos.where((t) => !t.isCompleted).length,
        ),
      );
    } catch (e) {
      debugPrint('Error refreshing counts: $e');
    }
  }

  Future<void> _onFilterChanged(
    TodoFilterChanged event,
    Emitter<TodoState> emit,
  ) async {
    emit(
      state.copyWith(
        currentFilter: event.filter,
        currentListId: event.listId,
        isLoading: true,
      ),
    );

    try {
      final todos = switch (event.filter) {
        TodoFilter.myDay => await _firebaseService.getMyDayTodos(),
        TodoFilter.important => await _firebaseService.getImportantTodos(),
        TodoFilter.planned => await _firebaseService.getPlannedTodos(),
        TodoFilter.assignedToMe =>
          await _firebaseService.getAssignedToMeTodos(null),
        TodoFilter.customList => event.listId != null
            ? await _firebaseService.getTodosByListId(event.listId!)
            : state.todos,
        TodoFilter.all ||
        TodoFilter.tasks =>
          await _firebaseService.getAllTodos(),
      };

      emit(
        state.copyWith(
          todos: todos,
          filteredTodos: _applyFilter(todos, state.searchQuery),
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to filter todos: $e',
          isLoading: false,
        ),
      );
    }
    event.completer?.complete();
  }

  Future<void> _onSearchChanged(
    TodoSearchChanged event,
    Emitter<TodoState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        emit(
          state.copyWith(
            searchQuery: event.query,
            filteredTodos: _applyFilter(state.todos, event.query),
          ),
        );
      } else {
        final results = await _firebaseService.searchTodos(event.query);
        emit(state.copyWith(searchQuery: event.query, filteredTodos: results));
      }
    } finally {
      event.completer?.complete();
    }
  }

  void _onSearchCleared(TodoSearchCleared event, Emitter<TodoState> emit) {
    emit(
      state.copyWith(
        searchQuery: '',
        filteredTodos: _applyFilter(state.todos, ''),
      ),
    );
  }

  Future<void> _onTodoAddRequested(
    TodoAddRequested event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final now = DateTime.now();
      final todo = TodoModel(
        title: event.title,
        description: event.description,
        isImportant: event.isImportant,
        isMyDay: event.isMyDay,
        dueDate: event.dueDate,
        assignedTo: event.assignedTo,
        assignedToName: event.assignedToName,
        listId: event.listId ?? state.currentListId,
        sortOrder: state.todos.length,
        createdAt: now,
        updatedAt: now,
      );

      final firebaseId = await _firebaseService.insertTodo(todo);
      final newTodo = todo.copyWith(firebaseId: firebaseId);
      final todos = [newTodo, ...state.todos];
      emit(
        state.copyWith(
          todos: todos,
          filteredTodos: _applyFilter(todos, state.searchQuery),
        ),
      );
      await _refreshCounts(emit);
      event.completer.complete(newTodo);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add todo: $e'));
      event.completer.complete(null);
    }
  }

  Future<void> _onTodoUpdateRequested(
    TodoUpdateRequested event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final updatedTodo = event.todo.copyWith(updatedAt: DateTime.now());
      await _firebaseService.updateTodo(updatedTodo);

      final todos = [...state.todos];
      final index =
          todos.indexWhere((t) => t.firebaseId == event.todo.firebaseId);
      if (index != -1) todos[index] = updatedTodo;

      emit(
        state.copyWith(
          todos: todos,
          filteredTodos: _applyFilter(todos, state.searchQuery),
        ),
      );
      await _refreshCounts(emit);
      event.completer.complete(true);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update todo: $e'));
      event.completer.complete(false);
    }
  }

  Future<void> _onTodoDeleteRequested(
    TodoDeleteRequested event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final firebaseId = event.todo.firebaseId;
      if (firebaseId == null) {
        event.completer.complete(false);
        return;
      }

      await _firebaseService.deleteTodo(firebaseId,
          ownerUid: event.todo.ownerUid);
      final todos =
          state.todos.where((t) => t.firebaseId != firebaseId).toList();
      emit(
        state.copyWith(
          todos: todos,
          filteredTodos: _applyFilter(todos, state.searchQuery),
        ),
      );
      await _refreshCounts(emit);
      event.completer.complete(true);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete todo: $e'));
      event.completer.complete(false);
    }
  }

  Future<void> _onReportTaskCreateRequested(
    TodoReportTaskCreateRequested event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final now = DateTime.now();
      final todo = TodoModel(
        title: event.reportName,
        description: event.description,
        reportId: event.reportId,
        isImportant: event.isImportant,
        dueDate: event.dueDate,
        isCompleted: false,
        isMyDay: false,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );

      final firebaseId = await _firebaseService.insertTodo(todo);
      final newTodo = todo.copyWith(firebaseId: firebaseId);
      final todos = [newTodo, ...state.todos];
      emit(
        state.copyWith(
          todos: todos,
          filteredTodos: _applyFilter(todos, state.searchQuery),
        ),
      );
      await _refreshCounts(emit);
      event.completer.complete(newTodo);
    } catch (e) {
      emit(state.copyWith(
          errorMessage: 'Failed to create task from report: $e'));
      event.completer.complete(null);
    }
  }

  Future<void> _onCompleteToggled(
    TodoCompleteToggled event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final firebaseId = event.todo.firebaseId;
      if (firebaseId == null) return;

      final index = state.todos.indexWhere((t) => t.firebaseId == firebaseId);
      if (index != -1) {
        final currentTodo = state.todos[index];
        final newValue = !currentTodo.isCompleted;
        await _firebaseService.toggleTodoComplete(
          firebaseId,
          newValue,
          ownerUid: currentTodo.ownerUid,
        );
        final todos = [...state.todos];
        todos[index] = currentTodo.copyWith(
          isCompleted: newValue,
          updatedAt: DateTime.now(),
        );
        emit(
          state.copyWith(
            todos: todos,
            filteredTodos: _applyFilter(todos, state.searchQuery),
          ),
        );
        await _refreshCounts(emit);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to toggle complete: $e'));
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onImportantToggled(
    TodoImportantToggled event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final firebaseId = event.todo.firebaseId;
      if (firebaseId == null) return;

      final index = state.todos.indexWhere((t) => t.firebaseId == firebaseId);
      if (index != -1) {
        final currentTodo = state.todos[index];
        final newValue = !currentTodo.isImportant;
        await _firebaseService.toggleTodoImportant(
          firebaseId,
          newValue,
          ownerUid: currentTodo.ownerUid,
        );
        final todos = [...state.todos];
        todos[index] = currentTodo.copyWith(
          isImportant: newValue,
          updatedAt: DateTime.now(),
        );
        emit(
          state.copyWith(
            todos: todos,
            filteredTodos: _applyFilter(todos, state.searchQuery),
          ),
        );
        await _refreshCounts(emit);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to toggle important: $e'));
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onMyDayToggled(
    TodoMyDayToggled event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final firebaseId = event.todo.firebaseId;
      if (firebaseId == null) return;

      final index = state.todos.indexWhere((t) => t.firebaseId == firebaseId);
      if (index != -1) {
        final currentTodo = state.todos[index];
        final newValue = !currentTodo.isMyDay;
        await _firebaseService.toggleTodoMyDay(
          firebaseId,
          newValue,
          ownerUid: currentTodo.ownerUid,
        );
        final todos = [...state.todos];
        todos[index] = currentTodo.copyWith(
          isMyDay: newValue,
          updatedAt: DateTime.now(),
        );
        emit(
          state.copyWith(
            todos: todos,
            filteredTodos: _applyFilter(todos, state.searchQuery),
          ),
        );
        await _refreshCounts(emit);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to toggle my day: $e'));
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onReorderRequested(
    TodoReorderRequested event,
    Emitter<TodoState> emit,
  ) async {
    var newIndex = event.newIndex;
    if (event.oldIndex < newIndex) newIndex -= 1;

    final filtered = [...state.filteredTodos];
    final todo = filtered.removeAt(event.oldIndex);
    filtered.insert(newIndex, todo);
    await _firebaseService.updateTodoOrder(filtered);
    emit(state.copyWith(filteredTodos: filtered));
    event.completer?.complete();
  }

  Future<void> _onListAddRequested(
    TodoListAddRequested event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final now = DateTime.now();
      final list = TodoListModel(
        name: event.name,
        iconName: event.iconName,
        color: event.color,
        sortOrder: state.todoLists.length,
        createdAt: now,
        updatedAt: now,
      );

      final firebaseId = await _firebaseService.insertTodoList(list);
      final newList = list.copyWith(firebaseId: firebaseId);
      emit(state.copyWith(todoLists: [...state.todoLists, newList]));
      event.completer.complete(newList);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add list: $e'));
      event.completer.complete(null);
    }
  }

  Future<void> _onListUpdateRequested(
    TodoListUpdateRequested event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final updatedList = event.list.copyWith(updatedAt: DateTime.now());
      await _firebaseService.updateTodoList(updatedList);
      final lists = [...state.todoLists];
      final index =
          lists.indexWhere((l) => l.firebaseId == event.list.firebaseId);
      if (index != -1) lists[index] = updatedList;
      emit(state.copyWith(todoLists: lists));
      event.completer.complete(true);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update list: $e'));
      event.completer.complete(false);
    }
  }

  Future<void> _onListDeleteRequested(
    TodoListDeleteRequested event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await _firebaseService.deleteTodoList(event.firebaseId);
      final lists = state.todoLists
          .where((l) => l.firebaseId != event.firebaseId)
          .toList();
      emit(state.copyWith(todoLists: lists));
      if (state.currentListId == event.firebaseId) {
        await _setFilterDirect(emit, TodoFilter.all);
      }
      event.completer.complete(true);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete list: $e'));
      event.completer.complete(false);
    }
  }

  void _onErrorCleared(TodoErrorCleared event, Emitter<TodoState> emit) {
    emit(state.copyWith(errorMessage: null));
  }

  Future<void> _onTodoStreamChanged(
    TodoStreamChanged event,
    Emitter<TodoState> emit,
  ) async {
    emit(
      state.copyWith(
        todos: event.todos,
        filteredTodos: _applyFilter(event.todos, state.searchQuery),
      ),
    );
    await _refreshCounts(emit);
  }

  void _onTodoListsStreamChanged(
    TodoListsStreamChanged event,
    Emitter<TodoState> emit,
  ) {
    emit(state.copyWith(todoLists: event.lists));
  }

  void _onTeamMembersLoaded(
    TodoTeamMembersLoaded event,
    Emitter<TodoState> emit,
  ) {
    emit(state.copyWith(teamMembers: event.members));
  }

  Future<void> _setFilterDirect(
    Emitter<TodoState> emit,
    TodoFilter filter, {
    String? listId,
  }) async {
    await _onFilterChanged(
      TodoFilterChanged(filter: filter, listId: listId),
      emit,
    );
  }

  List<TodoModel> _applyFilter(List<TodoModel> todos, String searchQuery) {
    if (searchQuery.isEmpty) return List.from(todos);
    final lower = searchQuery.toLowerCase();
    return todos
        .where(
          (todo) =>
              todo.title.toLowerCase().contains(lower) ||
              (todo.description?.toLowerCase().contains(lower) ?? false),
        )
        .toList();
  }

  void _setupStreams() {
    _todosSubscription ??= _firebaseService.streamAllTodos().listen(
          (todos) => add(TodoStreamChanged(todos)),
          onError: (e) => debugPrint('Error in todos stream: $e'),
        );

    _listsSubscription ??= _firebaseService.streamAllTodoLists().listen(
          (lists) => add(TodoListsStreamChanged(lists)),
          onError: (e) => debugPrint('Error in lists stream: $e'),
        );
  }

  @override
  Future<void> close() async {
    await _todosSubscription?.cancel();
    await _listsSubscription?.cancel();
    return super.close();
  }
}
