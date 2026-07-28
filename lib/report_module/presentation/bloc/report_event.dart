import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:el_race/report_module/data/models/folder_model.dart';
import 'package:el_race/report_module/data/models/report_detail_model.dart';
import 'package:el_race/report_module/data/models/report_item_model.dart';
import 'package:el_race/report_module/data/models/report_model.dart';
import 'package:el_race/report_module/data/models/report_pdf_model.dart';

typedef ReportUploadProgressCallback = void Function(double progress);

sealed class ReportEvent {
  const ReportEvent();
}

final class ReportInitialized extends ReportEvent {
  const ReportInitialized({required this.base, this.completer});

  final String base;
  final Completer<void>? completer;
}

final class ReportFoldersRequested extends ReportEvent {
  const ReportFoldersRequested({this.projectId, this.completer});

  final String? projectId;
  final Completer<void>? completer;
}

final class ReportFolderCreateRequested extends ReportEvent {
  const ReportFolderCreateRequested({
    required this.title,
    this.description = '',
    this.projectId,
    this.requireProject = false,
    this.completer,
  });

  final String title;
  final String description;
  final String? projectId;
  final bool requireProject;
  final Completer<void>? completer;
}

final class FolderProjectCreateRequested extends ReportEvent {
  const FolderProjectCreateRequested({
    required this.projectId,
    required this.title,
    this.description = '',
    required this.completer,
  });

  final String projectId;
  final String title;
  final String description;
  final Completer<FolderModel?> completer;
}

final class FolderReportsRequested extends ReportEvent {
  const FolderReportsRequested({
    required this.folderId,
    this.projectId,
    this.completer,
  });

  final String folderId;
  final String? projectId;
  final Completer<void>? completer;
}

final class ReportCreateRequested extends ReportEvent {
  const ReportCreateRequested({
    required this.title,
    required this.folderId,
    this.companyName,
    this.reportType,
    required this.completer,
  });

  final String title;
  final String folderId;
  final String? companyName;
  final String? reportType;
  final Completer<ReportModel?> completer;
}

final class ReportDeleteRequested extends ReportEvent {
  const ReportDeleteRequested({required this.reportId, this.completer});

  final String reportId;
  final Completer<void>? completer;
}

final class ReportRenameRequested extends ReportEvent {
  const ReportRenameRequested({
    required this.name,
    required this.reportId,
    this.completer,
  });

  final String name;
  final String reportId;
  final Completer<void>? completer;
}

final class ReportStateSynced extends ReportEvent {
  const ReportStateSynced();
}

final class ReportDetailRequested extends ReportEvent {
  const ReportDetailRequested({
    required this.report,
    required this.completer,
  });

  final ReportModel report;
  final Completer<ReportDetailModel?> completer;
}

final class ReportDetailUpdateRequested extends ReportEvent {
  const ReportDetailUpdateRequested({
    required this.reportDetail,
    this.completer,
  });

  final ReportDetailModel reportDetail;
  final Completer<void>? completer;
}

final class ReportCoverDeleteRequested extends ReportEvent {
  const ReportCoverDeleteRequested({
    required this.reportDetail,
    required this.completer,
  });

  final ReportDetailModel reportDetail;
  final Completer<bool> completer;
}

final class ReportPdfsRequested extends ReportEvent {
  const ReportPdfsRequested({
    required this.empId,
    required this.reportId,
    required this.folderId,
    required this.completer,
  });

  final String empId;
  final String reportId;
  final String folderId;
  final Completer<List<ReportPdfModel>> completer;
}

final class ReportPdfUploadRequested extends ReportEvent {
  const ReportPdfUploadRequested({
    required this.empId,
    required this.pdfBytes,
    required this.reportId,
    required this.folderId,
    required this.fileName,
    this.onProgress,
    required this.completer,
  });

  final String empId;
  final Uint8List pdfBytes;
  final String reportId;
  final String folderId;
  final String fileName;
  final ReportUploadProgressCallback? onProgress;
  final Completer<ReportPdfModel?> completer;
}

final class ReportPdfDeleteRequested extends ReportEvent {
  const ReportPdfDeleteRequested({
    required this.fileId,
    required this.completer,
  });

  final String fileId;
  final Completer<bool> completer;
}

final class ReportPdfRenameRequested extends ReportEvent {
  const ReportPdfRenameRequested({
    required this.fileId,
    required this.newFileName,
    required this.completer,
  });

  final String fileId;
  final String newFileName;
  final Completer<bool> completer;
}

final class ReportDetailApiRequested extends ReportEvent {
  const ReportDetailApiRequested({
    required this.reportId,
    required this.completer,
  });

  final String reportId;
  final Completer<ReportDetailModel?> completer;
}

final class ReportItemAddRequested extends ReportEvent {
  const ReportItemAddRequested({
    required this.reportId,
    required this.imageFile,
    required this.location,
    required this.description,
    this.type = 'image',
    this.index = 0,
    required this.completer,
  });

  final String reportId;
  final File imageFile;
  final String location;
  final String description;
  final String type;
  final int index;
  final Completer<ReportItemModel?> completer;
}

final class ReportItemUpdateRequested extends ReportEvent {
  const ReportItemUpdateRequested({
    required this.reportId,
    required this.itemId,
    this.location,
    this.description,
    this.imageFile,
    this.index = 0,
    required this.completer,
  });

  final String reportId;
  final String itemId;
  final String? location;
  final String? description;
  final File? imageFile;
  final int index;
  final Completer<ReportItemModel?> completer;
}

final class ReportItemDeleteRequested extends ReportEvent {
  const ReportItemDeleteRequested({
    required this.reportId,
    required this.itemId,
    required this.completer,
  });

  final String reportId;
  final String itemId;
  final Completer<bool> completer;
}

final class FolderSingleReportRequested extends ReportEvent {
  const FolderSingleReportRequested({
    required this.folder,
    required this.completer,
  });

  final FolderModel folder;
  final Completer<ReportModel?> completer;
}

final class SiteReportCreateRequested extends ReportEvent {
  const SiteReportCreateRequested({
    required this.title,
    this.reportType,
    required this.completer,
  });

  final String title;
  final String? reportType;
  final Completer<ReportModel?> completer;
}

final class ReportTypePersistRequested extends ReportEvent {
  const ReportTypePersistRequested({
    required this.reportId,
    required this.reportType,
    this.completer,
  });

  final String reportId;
  final String reportType;
  final Completer<void>? completer;
}

final class SiteReportsRequested extends ReportEvent {
  const SiteReportsRequested({
    this.offset = 0,
    this.limit = 15,
    this.append = false,
    required this.completer,
  });

  final int offset;
  final int limit;
  final bool append;
  final Completer<({List<ReportModel> reports, int total, bool hasMore})>
      completer;
}
