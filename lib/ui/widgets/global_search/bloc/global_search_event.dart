import 'package:equatable/equatable.dart';

sealed class GlobalSearchEvent extends Equatable {
  const GlobalSearchEvent();

  @override
  List<Object?> get props => [];
}

final class GlobalSearchQueryChanged extends GlobalSearchEvent {
  const GlobalSearchQueryChanged({
    required this.keyword,
    this.limitPerCategory = 5,
  });

  final String keyword;
  final int limitPerCategory;

  @override
  List<Object?> get props => [keyword, limitPerCategory];
}

final class GlobalSearchImmediateRequested extends GlobalSearchEvent {
  const GlobalSearchImmediateRequested({
    required this.keyword,
    this.limitPerCategory = 5,
  });

  final String keyword;
  final int limitPerCategory;

  @override
  List<Object?> get props => [keyword, limitPerCategory];
}

final class GlobalSearchRetryRequested extends GlobalSearchEvent {
  const GlobalSearchRetryRequested();
}

final class GlobalSearchCleared extends GlobalSearchEvent {
  const GlobalSearchCleared();
}

final class GlobalSearchCategoryLoadMoreRequested extends GlobalSearchEvent {
  const GlobalSearchCategoryLoadMoreRequested({
    required this.category,
  });

  final String category;

  @override
  List<Object?> get props => [category];
}
