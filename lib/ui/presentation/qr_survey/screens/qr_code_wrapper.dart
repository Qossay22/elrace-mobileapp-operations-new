import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/qr_survey_bloc.dart';
import '../bloc/qr_survey_state.dart';
import 'list_questions_screen.dart';
import 'list_documents_screen.dart';
import 'list_media_screen.dart';

/// Central wrapper that displays content based on the type from provider
class QrCodeWrapper extends StatelessWidget {
  const QrCodeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QrSurveyBloc, QrSurveyState>(
      builder: (context, state) {
        // Check if content is from QR code
        if (!state.isFromQrCode) {
          // Not accessed via QR code - show error
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied'),
              backgroundColor: Colors.red,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'QR Code Required',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This content is only accessible by scanning a QR code. Please scan a valid QR code to access this content.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!state.hasContent) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
              backgroundColor: Colors.blue,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Display the appropriate screen based on content type
        switch (state.contentType) {
          case 'survey':
            return ListQuestionsScreen(
              questions: state.data as List<dynamic>,
              surveyId: state.surveyId!,
              title: state.title ?? 'Survey',
            );
          case 'documents':
            return ListDocumentsScreen(
              documents: state.data as List<dynamic>,
            );
          case 'media':
            return ListMediaScreen(
              mediaList: state.data as List<dynamic>,
            );
          default:
            return Scaffold(
              appBar: AppBar(
                title: const Text('Unknown Content'),
              ),
              body: const Center(
                child: Text('Unknown content type'),
              ),
            );
        }
      },
    );
  }
}
