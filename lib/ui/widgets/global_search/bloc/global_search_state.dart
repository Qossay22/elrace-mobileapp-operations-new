import 'package:el_race/data/models/global_search_item.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_translate/flutter_translate.dart';

enum GlobalSearchStatus {
  idle,
  loading,
  loaded,
  empty,
  error,
}

class GlobalSearchSection extends Equatable {
  const GlobalSearchSection({
    required this.category,
    required this.title,
    required this.items,
  });

  final String category;
  final String title;
  final List<GlobalSearchItem> items;

  @override
  List<Object?> get props => [category, title, items];
}

final class GlobalSearchState extends Equatable {
  const GlobalSearchState({
    this.status = GlobalSearchStatus.idle,
    this.results = const [],
    this.countsByCategory = const {},
    this.limitPerCategory = 5,
    this.loadingMoreCategory,
    this.errorMessage,
    this.currentKeyword = '',
  });

  static const List<String> sectionOrder = [
    'lpo',
    'petty_cash',
    'projects',
    'my_actions',
    'notes',
    'documents',
    'tasks',
  ];

  final GlobalSearchStatus status;
  final List<GlobalSearchItem> results;
  final Map<String, int> countsByCategory;
  final int limitPerCategory;
  final String? loadingMoreCategory;
  final String? errorMessage;
  final String currentKeyword;

  bool get isLoading => status == GlobalSearchStatus.loading;
  bool get hasResults => results.isNotEmpty;
  bool get hasError => status == GlobalSearchStatus.error;
  bool get isEmpty => status == GlobalSearchStatus.empty;

  List<GlobalSearchSection> get sections => _buildSections(results);

  bool hasMoreInCategory(String category) {
    final shown = results.where((e) => e.category == category).length;
    final total = countsByCategory[category];
    if (total != null && total > 0) {
      return shown < total;
    }
    return shown >= limitPerCategory && shown > 0;
  }

  bool isLoadingMoreInCategory(String category) =>
      loadingMoreCategory == category;

  GlobalSearchState copyWith({
    GlobalSearchStatus? status,
    List<GlobalSearchItem>? results,
    Map<String, int>? countsByCategory,
    int? limitPerCategory,
    String? loadingMoreCategory,
    bool clearLoadingMoreCategory = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? currentKeyword,
  }) {
    return GlobalSearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      countsByCategory: countsByCategory ?? this.countsByCategory,
      limitPerCategory: limitPerCategory ?? this.limitPerCategory,
      loadingMoreCategory: clearLoadingMoreCategory
          ? null
          : loadingMoreCategory ?? this.loadingMoreCategory,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      currentKeyword: currentKeyword ?? this.currentKeyword,
    );
  }

  List<GlobalSearchSection> _buildSections(List<GlobalSearchItem> items) {
    final grouped = <String, List<GlobalSearchItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final sections = <GlobalSearchSection>[];
    for (final cat in sectionOrder) {
      final list = grouped[cat];
      if (list == null || list.isEmpty) continue;
      sections.add(GlobalSearchSection(
        category: cat,
        title: _sectionTitle(cat),
        items: list,
      ));
    }

    for (final entry in grouped.entries) {
      if (sectionOrder.contains(entry.key)) continue;
      sections.add(GlobalSearchSection(
        category: entry.key,
        title: entry.key,
        items: entry.value,
      ));
    }
    return sections;
  }

  String _sectionTitle(String category) {
    switch (category) {
      case 'lpo':
        return translate('search.category_lpo');
      case 'petty_cash':
        return translate('search.category_petty_cash');
      case 'projects':
        return translate('search.category_projects');
      case 'my_actions':
        return translate('search.category_my_actions');
      case 'notes':
        return translate('search.category_notes');
      case 'documents':
        return translate('search.category_documents');
      case 'tasks':
        return translate('search.category_tasks');
      default:
        return category;
    }
  }

  @override
  List<Object?> get props => [
        status,
        results,
        countsByCategory,
        limitPerCategory,
        loadingMoreCategory,
        errorMessage,
        currentKeyword,
      ];
}
