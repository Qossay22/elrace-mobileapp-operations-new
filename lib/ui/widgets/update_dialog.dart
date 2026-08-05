import 'package:el_race/core/update/bloc/app_update_bloc.dart';
import 'package:el_race/core/update/bloc/app_update_event.dart';
import 'package:el_race/core/update/bloc/app_update_state.dart';
import 'package:el_race/core/utils/responsive_breakpoints.dart';
import 'package:el_race/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  static Future<bool> showIfNeeded(
    BuildContext context,
    AppUpdateState state,
  ) async {
    if (!state.forceUpdateRequired) return false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<AppUpdateBloc>(),
        child: const UpdateDialog(),
      ),
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUpdateBloc, AppUpdateState>(
      builder: (context, state) {
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        final title = isArabic ? 'تحديث مطلوب' : 'Update Required';
        final message = isArabic
            ? 'يتوفر إصدار جديد من التطبيق. يرجى التحديث للمتابعة.'
            : 'A new app version is available. Please update to continue.';
        final buttonLabel = isArabic ? 'تحديث' : 'Update';

        return PopScope(
          canPop: false,
          child: Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 32.tw),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.tr),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.tr),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 58.tr,
                    height: 58.tr,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appFontColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.system_update_alt_rounded,
                      color: appFontColor,
                      size: 32.tr,
                    ),
                  ),
                  SizedBox(height: 16.th),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18.tsp,
                      fontWeight: FontWeight.w700,
                      color: appFontColor,
                    ),
                  ),
                  SizedBox(height: 10.th),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13.tsp,
                      height: 1.45,
                      color: const Color(0xFF4F5B67),
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    SizedBox(height: 12.th),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.tsp,
                        color: const Color(0xFFBA1719),
                      ),
                    ),
                  ],
                  SizedBox(height: 22.th),
                  ElevatedButton(
                    onPressed: state.isStartingUpdate
                        ? null
                        : () {
                            context
                                .read<AppUpdateBloc>()
                                .add(const AppRequiredUpdateStarted());
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appFontColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: appFontColor.withOpacity(0.55),
                      padding: EdgeInsets.symmetric(vertical: 13.th),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.tr),
                      ),
                      elevation: 0,
                    ),
                    child: state.isStartingUpdate
                        ? SizedBox(
                            width: 18.tr,
                            height: 18.tr,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            buttonLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 14.tsp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
