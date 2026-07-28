# BLoC Migration Architecture

Date: 2026-07-22

## Decision

The project standard state management pattern is **BLoC / flutter_bloc**.

Existing Riverpod and GetX code must be migrated gradually by feature. Provider/ChangeNotifier markers have been cleared from `lib`. The app behavior, business flows, API contracts, routes, Firebase structure, assets, and visual identity must stay unchanged during migration.

## Why BLoC

- The project already uses BLoC in important areas such as sign-in, home, media, QR code, notes, requests, and document scanner.
- BLoC gives explicit events, explicit states, and predictable testable transitions.
- It fits the current app size better than mixing ChangeNotifier, Riverpod Notifiers, GetX controllers, and BLoC in the same user journeys.
- It allows safer migration because old features can run beside new BLoC features until each feature is verified.

## Non-Negotiable Rules

1. Do not change product behavior during migration.
2. Do not change API endpoints, payload shapes, Firebase collections, or route names unless a feature task explicitly requires it.
3. Do not move a feature and rewrite its state management in the same unverified step if the feature is high risk.
4. Every migrated feature must keep a compatibility wrapper if existing screens still import the old provider/controller.
5. New feature work must use BLoC by default.
6. New Provider, Riverpod, or GetX state should not be introduced unless documented as a temporary bridge.

## Target Feature Structure

Use this structure for migrated and new features:

```text
lib/features/<feature_name>/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    bloc/
      <feature_name>_bloc.dart
      <feature_name>_event.dart
      <feature_name>_state.dart
    screens/
    widgets/
```

Legacy feature folders under `lib/ui/presentation`, `lib/core`, or `lib/providers` may remain until their feature migration is complete.

## BLoC File Rules

### Event

- Events describe user intent or lifecycle triggers.
- Event names should be past-tense or command-like and feature-scoped.
- Events should not contain `BuildContext`.
- Events should carry primitive values, IDs, DTOs, or domain entities only.

Example:

```dart
sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

final class TasksRequested extends TasksEvent {
  const TasksRequested();
}

final class TaskStatusChanged extends TasksEvent {
  const TaskStatusChanged({
    required this.taskId,
    required this.isCompleted,
  });

  final String taskId;
  final bool isCompleted;

  @override
  List<Object?> get props => [taskId, isCompleted];
}
```

### State

- State is immutable.
- State includes status, data, and failure message/object where needed.
- Avoid multiple booleans such as `isLoading`, `hasError`, `isEmpty` when a status enum is clearer.

Example:

```dart
enum TasksStatus { initial, loading, success, failure }

final class TasksState extends Equatable {
  const TasksState({
    this.status = TasksStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final TasksStatus status;
  final List<TaskEntity> items;
  final String? errorMessage;

  TasksState copyWith({
    TasksStatus? status,
    List<TaskEntity>? items,
    String? errorMessage,
  }) {
    return TasksState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
```

### Bloc

- BLoC talks to use cases or repositories.
- BLoC should not directly call widgets, navigation, snackbars, or dialogs.
- UI side effects belong in `BlocListener`.
- API exceptions should become typed failure states.

## Dependency Injection

The current `get_it` service locator can remain as the dependency injection mechanism during migration.

Rules:

- Register repositories and BLoCs in feature-specific registration functions.
- Avoid resolving dependencies inside widgets when a `BlocProvider` can provide the BLoC.
- Avoid global singletons for short-lived screen BLoCs.

Example:

```dart
void registerTasksFeature() {
  sl.registerLazySingleton<TasksRepository>(() => TasksRepositoryImpl(sl()));
  sl.registerFactory(() => TasksBloc(repository: sl()));
}
```

## Migration Order

Use risk-based order. Start with features that are smaller or already close to BLoC.

| Priority | Feature | Current Pattern | Risk | Migration Notes |
|---:|---|---|---|---|
| 1 | QR Survey | Provider | Low/Medium | Convert `QrSurveyDataProvider` to BLoC, keep screen behavior unchanged. |
| 2 | Global Search | ChangeNotifier Provider | Medium | Convert search text, filters, history, and results to BLoC. |
| 3 | Announcements / News | ChangeNotifier Provider | Low | Good early migration target. |
| 4 | Home Slider | ChangeNotifier Provider | Low/Medium | Convert slider items, loading, page index, and refresh state to BLoC. |
| 5 | Tasks / Tickets | ChangeNotifier Provider | Medium/High | Convert task list, detail actions, report linking, and home ticket cards to BLoC. |
| 6 | Todo / Task Dashboard | ChangeNotifier Provider + BLoC nearby | Medium/High | Convert Firebase-backed todo streams, filters, counts, and dashboard state to BLoC. |
| 7 | Reports | BLoC + Repository | Medium/High | Legacy ReportProvider removed; presentation is routed through ReportBloc; ReportRepository focused analysis is clean; continue by splitting repository responsibilities and adding tests. |
| 8 | Home Widget Cards | Riverpod | High | Build a `HomeDashboardBloc` facade first. |
| 9 | HR / Recruitment / Payslip / Performance | Riverpod | High | Create BLoC facades per module before replacing Riverpod screens. |
| 10 | Timesheet / Site Management | Riverpod | Very High | Migrate last; it is business-critical and deeply wired. |
| 11 | GetX Timer / Instruction | GetX | Medium | Replace with `TimerBloc` and route argument objects. |

## Provider to BLoC Mapping

| Old Pattern | New Pattern |
|---|---|
| `ChangeNotifier` field | immutable BLoC state field |
| `notifyListeners()` | `emit(state.copyWith(...))` |
| provider method called by UI | BLoC event |
| `Consumer<T>` | `BlocBuilder<TBloc, TState>` |
| provider side effect | `BlocListener<TBloc, TState>` |
| provider async method | event handler with loading/success/failure |

## Riverpod to BLoC Mapping

| Old Pattern | New Pattern |
|---|---|
| `Provider<T>` | repository/use case in DI |
| `FutureProvider<T>` | BLoC event + loading/success/failure state |
| `NotifierProvider<TNotifier, T>` | BLoC with events for every mutation |
| `AsyncNotifierProvider` | BLoC with status and error fields |
| `ConsumerWidget` | `StatelessWidget` or `StatefulWidget` with `BlocBuilder` |
| `ref.watch(...)` | `context.select` or `BlocSelector` |
| `ref.read(...).method()` | `context.read<Bloc>().add(Event())` |

## GetX to BLoC Mapping

| Old Pattern | New Pattern |
|---|---|
| `GetxController` | BLoC |
| `Rx<T>` | state field |
| `Obx` | `BlocBuilder` |
| `Get.find<T>()` | `context.read<TBloc>()` or DI registration |
| `Get.arguments` | typed route arguments |

## Verification Checklist Per Feature

Before marking a feature migrated:

- The old user flow still works.
- The same route names and arguments still work.
- The same API calls are made with the same payload shape.
- Loading, empty, success, and failure states are represented.
- Existing local persistence behavior is preserved.
- At least smoke tests or widget tests are added.
- No new Provider/Riverpod/GetX state is introduced.
- `flutter test` passes after the feature.

## Current Verification Status

- `AssetManifest.json` was removed from `pubspec.yaml` because it was referenced as an asset but did not exist.
- `flutter test` no longer stops immediately on that missing asset, but the full test run did not finish within the 3-minute command timeout during this audit. Run focused feature tests during each migration step.
- `flutter test test\widget_test.dart` now reaches compilation and fails on a separate Flutter SDK/dependency mismatch: `Required named parameter 'hitTestTransform' must be provided` from Flutter semantics.
- `scripts/state_management_audit.ps1` can be used to track remaining non-BLoC usage.

## Recommended First Migration

Completed first migrations:

- Announcements / News screen
- QR Survey
- Global Search
- Profile Box
- Home Slider
- Tasks / Tickets
- Todo / Task Dashboard
- Reports foundation / task-linked reports
- Report detail local storage
- Report PDF history / upload facade
- Report photos item CRUD / image capture facade
- Report dialogs / remaining report-module provider bridges
- Timesheet/Site Reports shared actions / PDF facade
- Timesheet Site Reports composer/gallery and project tab facade
- Project Analytics site report tab facade
- Remove root ReportProvider registration
- Remove temporary ReportProvider.empID presentation imports
- Remove report global provider getter and Provider imports from migrated presentation
- Replace ReportProvider backend facade with ReportRepository
- Clean ReportRepository lint
- Clear remaining Provider/ChangeNotifier markers
- Home Notes widget card Riverpod-to-BLoC
- Home Petty Cash widget card Riverpod-to-BLoC
- Home LPO widget card Riverpod-to-BLoC
- Home Library widget cards Riverpod-to-BLoC
- Remove unused Home Productivity Riverpod providers
- Home Timesheet widget card Riverpod-to-BLoC
- Home Projects widget cards Riverpod-to-BLoC
- Home Attendance and HRMS widget cards Riverpod-to-BLoC
- Remove Riverpod dependency from HomeWidgetRefreshService
- Remove unused Riverpod wrapper from HR Management menu
- Remove unused ConsumerWidget wrappers
- Timesheet entry mode Riverpod-to-BLoC
- Remove unused ConsumerStatefulWidget wrappers in Timesheet screens
- Remove face enrollment status service Provider
- Face match session Riverpod-to-BLoC
- Remove Riverpod from Payslip and Performance entry gates
- Remove unused face readiness providers
- Payslip employee month filter Riverpod-to-BLoC
- Employee Payslip screen data Riverpod-to-BLoC
- Payslip detail, HR list, and manager pending hub Riverpod-to-BLoC
- Performance planning screen Riverpod-to-BLoC
- Performance evaluation list and employee year/detail Riverpod-to-BLoC
- Performance manager evaluation detail screen Riverpod-to-BLoC
- Performance new evaluation workflow Riverpod-to-BLoC
- Recruitment candidate, assessment, and offer detail Riverpod-to-BLoC
- Recruitment requisition detail Riverpod-to-BLoC
- Recruitment landing and dashboard Riverpod-to-BLoC cleanup
- Purchase MR detail and invoice receiving detail/list Riverpod-to-BLoC cleanup
- Purchase Management hub Riverpod-to-BLoC
- Purchase RFQ hub Riverpod access cleanup
- Purchase provider removal and GetX cleanup
- HR request forms and request entry Riverpod cleanup
- HR Management landing/list Riverpod-to-BLoC cleanup

Recommended next migration: **Attendance Reports Riverpod providers, then Timesheet in smaller slices**, still keeping deeper Timesheet flows for later.
