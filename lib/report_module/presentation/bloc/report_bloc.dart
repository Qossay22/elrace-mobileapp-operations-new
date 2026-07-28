import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:el_race/report_module/data/models/folder_model.dart';
import 'package:el_race/report_module/data/models/report_detail_model.dart';
import 'package:el_race/report_module/data/models/report_item_model.dart';
import 'package:el_race/report_module/data/models/report_model.dart';
import 'package:el_race/report_module/data/models/report_pdf_model.dart';
import 'package:el_race/report_module/data/repositories/report_repository.dart';
import 'package:el_race/report_module/presentation/bloc/report_event.dart';
import 'package:el_race/report_module/presentation/bloc/report_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc([ReportRepository? repository])
      : _repository = repository ?? ReportRepository(),
        _ownsRepository = repository == null,
        super(const ReportState()) {
    on<ReportInitialized>(_onInitialized);
    on<ReportFoldersRequested>(_onFoldersRequested);
    on<ReportFolderCreateRequested>(_onFolderCreateRequested);
    on<FolderProjectCreateRequested>(_onFolderProjectCreateRequested);
    on<FolderReportsRequested>(_onFolderReportsRequested);
    on<ReportCreateRequested>(_onReportCreateRequested);
    on<ReportDeleteRequested>(_onReportDeleteRequested);
    on<ReportRenameRequested>(_onReportRenameRequested);
    on<ReportStateSynced>(_onStateSynced);
    on<ReportDetailRequested>(_onReportDetailRequested);
    on<ReportDetailUpdateRequested>(_onReportDetailUpdateRequested);
    on<ReportCoverDeleteRequested>(_onReportCoverDeleteRequested);
    on<ReportPdfsRequested>(_onReportPdfsRequested);
    on<ReportPdfUploadRequested>(_onReportPdfUploadRequested);
    on<ReportPdfDeleteRequested>(_onReportPdfDeleteRequested);
    on<ReportPdfRenameRequested>(_onReportPdfRenameRequested);
    on<ReportDetailApiRequested>(_onReportDetailApiRequested);
    on<ReportItemAddRequested>(_onReportItemAddRequested);
    on<ReportItemUpdateRequested>(_onReportItemUpdateRequested);
    on<ReportItemDeleteRequested>(_onReportItemDeleteRequested);
    on<FolderSingleReportRequested>(_onFolderSingleReportRequested);
    on<SiteReportCreateRequested>(_onSiteReportCreateRequested);
    on<ReportTypePersistRequested>(_onReportTypePersistRequested);
    on<SiteReportsRequested>(_onSiteReportsRequested);
  }

  final ReportRepository _repository;
  final bool _ownsRepository;

  List<FolderModel> get folders => state.folders;
  List<ReportModel> get reports => state.reports;
  bool get isLoading => state.isLoading;
  String get employeeId => ReportRepository.empID;

  Future<void> init({required String base}) {
    final completer = Completer<void>();
    add(ReportInitialized(base: base, completer: completer));
    return completer.future;
  }

  @override
  Future<void> close() {
    if (_ownsRepository) {
      _repository.dispose();
    }
    return super.close();
  }

  Future<void> fetchAllFolders({String? projectId}) {
    final completer = Completer<void>();
    add(ReportFoldersRequested(projectId: projectId, completer: completer));
    return completer.future;
  }

  Future<void> createFolder({
    required String title,
    String description = '',
    String? projectId,
    bool requireProject = false,
  }) {
    final completer = Completer<void>();
    add(
      ReportFolderCreateRequested(
        title: title,
        description: description,
        projectId: projectId,
        requireProject: requireProject,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<FolderModel?> createFolderForProject({
    required String projectId,
    required String title,
    String description = '',
  }) {
    final completer = Completer<FolderModel?>();
    add(
      FolderProjectCreateRequested(
        projectId: projectId,
        title: title,
        description: description,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<void> fetchAllReports({
    required String folderID,
    String? projectId,
  }) {
    final completer = Completer<void>();
    add(
      FolderReportsRequested(
        folderId: folderID,
        projectId: projectId,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<ReportModel?> createReport({
    required String title,
    required String folderID,
    String? companyName,
    String? reportType,
  }) {
    final completer = Completer<ReportModel?>();
    add(
      ReportCreateRequested(
        title: title,
        folderId: folderID,
        companyName: companyName,
        reportType: reportType,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<void> deleteReport({required String reportId}) {
    final completer = Completer<void>();
    add(ReportDeleteRequested(reportId: reportId, completer: completer));
    return completer.future;
  }

  Future<void> updateReport({
    required String name,
    required String reportId,
  }) {
    final completer = Completer<void>();
    add(
      ReportRenameRequested(
        name: name,
        reportId: reportId,
        completer: completer,
      ),
    );
    return completer.future;
  }

  void syncFromProvider() {
    add(const ReportStateSynced());
  }

  Future<ReportDetailModel?> getReportDetail(ReportModel report) {
    final completer = Completer<ReportDetailModel?>();
    add(ReportDetailRequested(report: report, completer: completer));
    return completer.future;
  }

  Future<void> updateReportDetail(ReportDetailModel reportDetail) {
    final completer = Completer<void>();
    add(
      ReportDetailUpdateRequested(
        reportDetail: reportDetail,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<bool> deleteCoverPage(ReportDetailModel reportDetail) {
    final completer = Completer<bool>();
    add(
      ReportCoverDeleteRequested(
        reportDetail: reportDetail,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<List<ReportPdfModel>> fetchReports({
    String? empId,
    required String reportId,
    required String folderId,
  }) {
    final completer = Completer<List<ReportPdfModel>>();
    add(
      ReportPdfsRequested(
        empId: empId ?? ReportRepository.empID,
        reportId: reportId,
        folderId: folderId,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<ReportPdfModel?> uploadReportPdf({
    String? empId,
    required Uint8List pdfBytes,
    required String reportId,
    required String folderId,
    required String fileName,
    ReportUploadProgressCallback? onProgress,
  }) {
    final completer = Completer<ReportPdfModel?>();
    add(
      ReportPdfUploadRequested(
        empId: empId ?? ReportRepository.empID,
        pdfBytes: pdfBytes,
        reportId: reportId,
        folderId: folderId,
        fileName: fileName,
        onProgress: onProgress,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<bool> deleteReportPdf({required String fileId}) {
    final completer = Completer<bool>();
    add(ReportPdfDeleteRequested(fileId: fileId, completer: completer));
    return completer.future;
  }

  Future<bool> renameReportPdf({
    required String fileId,
    required String newFileName,
  }) {
    final completer = Completer<bool>();
    add(
      ReportPdfRenameRequested(
        fileId: fileId,
        newFileName: newFileName,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<ReportDetailModel?> fetchReportDetailFromApi(String reportId) {
    final completer = Completer<ReportDetailModel?>();
    add(ReportDetailApiRequested(reportId: reportId, completer: completer));
    return completer.future;
  }

  Future<ReportItemModel?> addReportItem({
    required String reportId,
    required File imageFile,
    required String location,
    required String description,
    String type = 'image',
    int index = 0,
  }) {
    final completer = Completer<ReportItemModel?>();
    add(
      ReportItemAddRequested(
        reportId: reportId,
        imageFile: imageFile,
        location: location,
        description: description,
        type: type,
        index: index,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<ReportItemModel?> updateReportItem({
    required String reportId,
    required String itemId,
    String? location,
    String? description,
    File? imageFile,
    int index = 0,
  }) {
    final completer = Completer<ReportItemModel?>();
    add(
      ReportItemUpdateRequested(
        reportId: reportId,
        itemId: itemId,
        location: location,
        description: description,
        imageFile: imageFile,
        index: index,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<bool> deleteReportItem({
    required String reportId,
    required String itemId,
  }) {
    final completer = Completer<bool>();
    add(
      ReportItemDeleteRequested(
        reportId: reportId,
        itemId: itemId,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<ReportModel?> getOrCreateSingleReportForFolder(FolderModel folder) {
    final completer = Completer<ReportModel?>();
    add(FolderSingleReportRequested(folder: folder, completer: completer));
    return completer.future;
  }

  Future<ReportModel?> createSiteReport({
    required String title,
    String? reportType,
  }) {
    final completer = Completer<ReportModel?>();
    add(
      SiteReportCreateRequested(
        title: title,
        reportType: reportType,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<void> persistReportType(String reportId, String reportType) {
    final completer = Completer<void>();
    add(
      ReportTypePersistRequested(
        reportId: reportId,
        reportType: reportType,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<({List<ReportModel> reports, int total, bool hasMore})>
      fetchSiteReports({
    int offset = 0,
    int limit = 15,
    bool append = false,
  }) {
    final completer =
        Completer<({List<ReportModel> reports, int total, bool hasMore})>();
    add(
      SiteReportsRequested(
        offset: offset,
        limit: limit,
        append: append,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<void> _onInitialized(
    ReportInitialized event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.init(base: event.base);
      _sync(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isLoading: false));
      event.completer?.complete();
    }
  }

  Future<void> _onFoldersRequested(
    ReportFoldersRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.fetchAllFolders(projectId: event.projectId);
      _sync(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isLoading: false));
      event.completer?.complete();
    }
  }

  Future<void> _onFolderCreateRequested(
    ReportFolderCreateRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.createFolder(
        title: event.title,
        description: event.description,
        projectId: event.projectId,
        requireProject: event.requireProject,
      );
      _sync(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isLoading: false));
      event.completer?.complete();
    }
  }

  Future<void> _onFolderProjectCreateRequested(
    FolderProjectCreateRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final folder = await _repository.createFolderForProject(
        projectId: event.projectId,
        title: event.title,
        description: event.description,
      );
      _sync(emit);
      event.completer.complete(folder);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(null);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onFolderReportsRequested(
    FolderReportsRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.fetchAllReports(
        folderID: event.folderId,
        projectId: event.projectId,
      );
      _sync(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isLoading: false));
      event.completer?.complete();
    }
  }

  Future<void> _onReportCreateRequested(
    ReportCreateRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final report = await _repository.createReport(
        title: event.title,
        folderID: event.folderId,
        companyName: event.companyName,
        reportType: event.reportType,
      );
      _sync(emit);
      event.completer.complete(report);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(null);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onReportDeleteRequested(
    ReportDeleteRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.deleteReport(reportId: event.reportId);
      _sync(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isLoading: false));
      event.completer?.complete();
    }
  }

  Future<void> _onReportRenameRequested(
    ReportRenameRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.updateReport(
          name: event.name, reportId: event.reportId);
      _sync(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isLoading: false));
      event.completer?.complete();
    }
  }

  void _onStateSynced(ReportStateSynced event, Emitter<ReportState> emit) {
    _sync(emit);
  }

  Future<void> _onReportDetailRequested(
    ReportDetailRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final detail = await _repository.getReportDetail(event.report);
      event.completer.complete(detail);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(null);
    }
  }

  Future<void> _onReportDetailUpdateRequested(
    ReportDetailUpdateRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      await _repository.updateReportDetail(event.reportDetail);
      event.completer?.complete();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer?.complete();
    }
  }

  Future<void> _onReportCoverDeleteRequested(
    ReportCoverDeleteRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final deleted = await _repository.deleteCoverPage(event.reportDetail);
      event.completer.complete(deleted);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(false);
    }
  }

  Future<void> _onReportPdfsRequested(
    ReportPdfsRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final pdfs = await _repository.fetchReports(
        empId: event.empId,
        reportId: event.reportId,
        folderId: event.folderId,
      );
      event.completer.complete(pdfs);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(const []);
    }
  }

  Future<void> _onReportPdfUploadRequested(
    ReportPdfUploadRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final pdf = await _repository.uploadReportPdf(
        empId: event.empId,
        pdfBytes: event.pdfBytes,
        reportId: event.reportId,
        folderId: event.folderId,
        fileName: event.fileName,
        onProgress: event.onProgress,
      );
      _sync(emit);
      event.completer.complete(pdf);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(null);
    }
  }

  Future<void> _onReportPdfDeleteRequested(
    ReportPdfDeleteRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final deleted = await _repository.deleteReportPdf(fileId: event.fileId);
      event.completer.complete(deleted);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(false);
    }
  }

  Future<void> _onReportPdfRenameRequested(
    ReportPdfRenameRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final renamed = await _repository.renameReportPdf(
        fileId: event.fileId,
        newFileName: event.newFileName,
      );
      event.completer.complete(renamed);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(false);
    }
  }

  Future<void> _onReportDetailApiRequested(
    ReportDetailApiRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final detail = await _repository.fetchReportDetailFromApi(event.reportId);
      event.completer.complete(detail);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(null);
    }
  }

  Future<void> _onReportItemAddRequested(
    ReportItemAddRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final item = await _repository.addReportItem(
        reportId: event.reportId,
        imageFile: event.imageFile,
        location: event.location,
        description: event.description,
        type: event.type,
        index: event.index,
      );
      event.completer.complete(item);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(null);
    }
  }

  Future<void> _onReportItemUpdateRequested(
    ReportItemUpdateRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final item = await _repository.updateReportItem(
        reportId: event.reportId,
        itemId: event.itemId,
        location: event.location,
        description: event.description,
        imageFile: event.imageFile,
        index: event.index,
      );
      event.completer.complete(item);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(null);
    }
  }

  Future<void> _onReportItemDeleteRequested(
    ReportItemDeleteRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final deleted = await _repository.deleteReportItem(
        reportId: event.reportId,
        itemId: event.itemId,
      );
      event.completer.complete(deleted);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(false);
    }
  }

  Future<void> _onFolderSingleReportRequested(
    FolderSingleReportRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final report = await _repository.getOrCreateSingleReportForFolder(
        event.folder,
      );
      _sync(emit);
      event.completer.complete(report);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(null);
    }
  }

  Future<void> _onSiteReportCreateRequested(
    SiteReportCreateRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final report = await _repository.createSiteReport(
        title: event.title,
        reportType: event.reportType,
      );
      _sync(emit);
      event.completer.complete(report);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete(null);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onReportTypePersistRequested(
    ReportTypePersistRequested event,
    Emitter<ReportState> emit,
  ) async {
    try {
      await _repository.persistReportType(event.reportId, event.reportType);
      event.completer?.complete();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer?.complete();
    }
  }

  Future<void> _onSiteReportsRequested(
    SiteReportsRequested event,
    Emitter<ReportState> emit,
  ) async {
    if (!event.append) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }
    try {
      final result = await _repository.fetchSiteReports(
        offset: event.offset,
        limit: event.limit,
        append: event.append,
      );
      _sync(emit);
      event.completer.complete(result);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      event.completer.complete((
        reports: List<ReportModel>.from(_repository.reports),
        total: _repository.reports.length,
        hasMore: false,
      ));
    } finally {
      if (!event.append) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  void _sync(Emitter<ReportState> emit) {
    emit(
      state.copyWith(
        folders: List<FolderModel>.from(_repository.folders),
        reports: List<ReportModel>.from(_repository.reports),
        isLoading: _repository.isLoading,
      ),
    );
  }
}
