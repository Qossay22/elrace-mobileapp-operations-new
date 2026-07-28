import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el_race/ui/widgets/header_widget.dart';
import 'package:el_race/utils/color_utils.dart';
import '../bloc/qr_survey_bloc.dart';
import '../bloc/qr_survey_event.dart';
import '../bloc/qr_survey_state.dart';
import 'list_documents_screen.dart';
import 'list_media_screen.dart';
import 'list_questions_screen.dart';

/// Wrapper widget that displays QR Survey content within HomeScreen structure
/// This widget is shown as part of the MainScreen bottom navigation
class QrSurveyContentWrapper extends StatefulWidget {
  const QrSurveyContentWrapper({super.key});

  @override
  State<QrSurveyContentWrapper> createState() => _QrSurveyContentWrapperState();
}

class _QrSurveyContentWrapperState extends State<QrSurveyContentWrapper> {
  @override
  void deactivate() {
    // Clear QR data when leaving this screen/tab
    print('🧹 QrSurveyContentWrapper - deactivate - Clearing QR data');
    context.read<QrSurveyBloc>().add(const QrSurveyContentCleared());
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QrSurveyBloc, QrSurveyState>(
      builder: (context, state) {
        print('🔍 QrSurveyContentWrapper - Building');
        print('🔍 Content Type: ${state.contentType}');
        print('🔍 Content Data: ${state.contentData}');
        print('🔍 Data Array: ${state.data}');
        print('🔍 Is From QR Code: ${state.isFromQrCode}');

        // Check if content is from QR code
        if (!state.isFromQrCode) {
          // Not accessed via QR code - show access denied
          return Scaffold(
            appBar: const HeaderWidget(),
            backgroundColor: lightGrey,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      size: 100,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Scan QR Code to Access Content',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This section is only accessible by scanning a valid QR code. Please scan a QR code to view the content.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Get content from provider
        final contentType = state.contentType;
        final List<dynamic>? dataArray = state.data;

        // Show QR Survey content based on type
        Widget qrSurveyContent;
        if (contentType == 'survey') {
          final surveyData = state.contentData;
          qrSurveyContent = ListQuestionsScreen(
            questions: surveyData?['questions'] ?? [],
            surveyId: surveyData?['id'] ?? 0,
            title: surveyData?['title'] ?? 'Survey',
          );
        } else if (contentType == 'documents') {
          qrSurveyContent = ListDocumentsScreen(documents: dataArray ?? []);
        } else if (contentType == 'media') {
          print(
              '📱 Creating ListMediaScreen with ${dataArray?.length ?? 0} items');
          qrSurveyContent = ListMediaScreen(mediaList: dataArray ?? []);
        } else {
          qrSurveyContent = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Scan a QR code to view content',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Type: ${contentType ?? "null"}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: const HeaderWidget(),
          backgroundColor: lightGrey,
          body: qrSurveyContent,
        );
      },
    );
  }
}
