import 'package:equatable/equatable.dart';

sealed class QrSurveyEvent extends Equatable {
  const QrSurveyEvent();

  @override
  List<Object?> get props => [];
}

final class QrSurveyContentSet extends QrSurveyEvent {
  const QrSurveyContentSet({
    required this.contentData,
    this.fromQrCode = false,
  });

  final Map<String, dynamic>? contentData;
  final bool fromQrCode;

  @override
  List<Object?> get props => [contentData, fromQrCode];
}

final class QrSurveyContentCleared extends QrSurveyEvent {
  const QrSurveyContentCleared();
}
