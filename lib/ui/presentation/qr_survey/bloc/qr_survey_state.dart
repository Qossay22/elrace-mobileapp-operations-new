import 'package:equatable/equatable.dart';

final class QrSurveyState extends Equatable {
  const QrSurveyState({
    this.contentData,
    this.isFromQrCode = false,
  });

  final Map<String, dynamic>? contentData;
  final bool isFromQrCode;

  String? get contentType => contentData?['type'];

  List<dynamic>? get data => contentData?['data'];

  int? get surveyId => contentData?['survey_id'];

  String? get title => contentData?['title'];

  bool get hasContent => contentData != null;

  bool get isSurvey => contentType == 'survey';

  bool get isDocuments => contentType == 'documents';

  bool get isMedia => contentType == 'media';

  @override
  List<Object?> get props => [contentData, isFromQrCode];
}
