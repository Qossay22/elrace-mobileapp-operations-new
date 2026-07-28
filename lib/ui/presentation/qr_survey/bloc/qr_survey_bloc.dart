import 'package:bloc/bloc.dart';

import 'qr_survey_event.dart';
import 'qr_survey_state.dart';

class QrSurveyBloc extends Bloc<QrSurveyEvent, QrSurveyState> {
  QrSurveyBloc() : super(const QrSurveyState()) {
    on<QrSurveyContentSet>(_onContentSet);
    on<QrSurveyContentCleared>(_onContentCleared);
  }

  void _onContentSet(
    QrSurveyContentSet event,
    Emitter<QrSurveyState> emit,
  ) {
    emit(QrSurveyState(
      contentData: event.contentData,
      isFromQrCode: event.fromQrCode,
    ));
  }

  void _onContentCleared(
    QrSurveyContentCleared event,
    Emitter<QrSurveyState> emit,
  ) {
    emit(const QrSurveyState());
  }
}
