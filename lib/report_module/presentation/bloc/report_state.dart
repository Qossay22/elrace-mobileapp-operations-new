import 'package:el_race/report_module/data/models/folder_model.dart';
import 'package:el_race/report_module/data/models/report_model.dart';

class ReportState {
  const ReportState({
    this.folders = const [],
    this.reports = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<FolderModel> folders;
  final List<ReportModel> reports;
  final bool isLoading;
  final String? errorMessage;

  ReportState copyWith({
    List<FolderModel>? folders,
    List<ReportModel>? reports,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return ReportState(
      folders: folders ?? this.folders,
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();
}
