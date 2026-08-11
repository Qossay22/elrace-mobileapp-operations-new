import 'package:el_race/core/services/update_service.dart';
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
    final result = state.result;
    if (!result.forceUpdate && !result.optionalUpdate) return false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !result.forceUpdate,
      builder: (_) => BlocProvider.value(
        value: context.read<AppUpdateBloc>(),
        child: const UpdateDialog(),
      ),
    );

    return result.forceUpdate;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUpdateBloc, AppUpdateState>(
      builder: (context, state) {
        final result = state.result;
        final locale = Localizations.localeOf(context);
        final isArabic = locale.languageCode == 'ar';
        final isForce = result.forceUpdate;
        final title = isArabic
            ? (isForce ? 'تحديث إلزامي' : 'تحديث متاح')
            : (isForce ? 'Required Update' : 'Update Available');
        final message = _resolveMessage(result: result, isArabic: isArabic);
        final updateLabel = isArabic ? 'تحديث الآن' : 'Update Now';
        final laterLabel = isArabic ? 'لاحقاً' : 'Later';

        return PopScope(
          canPop: !isForce,
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 30.tw),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.tr),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(22.tw, 22.th, 22.tw, 18.th),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58.tr,
                      height: 58.tr,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEFEF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD7D8)),
                      ),
                      child: Icon(
                        Icons.system_update_alt_rounded,
                        size: 31.tr,
                        color: const Color(0xFFBA1719),
                      ),
                    ),
                    SizedBox(height: 14.th),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 17.tsp,
                        fontWeight: FontWeight.w700,
                        color: appFontColor,
                      ),
                    ),
                    SizedBox(height: 8.th),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13.tsp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF55596A),
                        height: 1.45,
                      ),
                    ),
                    if (result.latestVersion != null) ...[
                      SizedBox(height: 12.th),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.tw,
                          vertical: 5.th,
                        ),
                        decoration: BoxDecoration(
                          color: appFontColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'v${result.latestVersion}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.tsp,
                            fontWeight: FontWeight.w600,
                            color: appFontColor,
                          ),
                        ),
                      ),
                    ],
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: state.isStartingUpdate
                            ? null
                            : () {
                                context
                                    .read<AppUpdateBloc>()
                                    .add(const AppRequiredUpdateStarted());
                              },
                        icon: state.isStartingUpdate
                            ? SizedBox(
                                width: 18.tr,
                                height: 18.tr,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.open_in_new_rounded, size: 19),
                        label: Text(updateLabel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appFontColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              appFontColor.withValues(alpha: 0.55),
                          padding: EdgeInsets.symmetric(vertical: 13.th),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.tr),
                          ),
                          elevation: 0,
                          textStyle: GoogleFonts.poppins(
                            fontSize: 14.tsp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (!isForce) ...[
                      SizedBox(height: 8.th),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          laterLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 13.tsp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF747789),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _resolveMessage({
    required bool isArabic,
    required UpdateCheckResult result,
  }) {
    if (isArabic && (result.updateMessageAr?.trim().isNotEmpty ?? false)) {
      return result.updateMessageAr!.trim();
    }
    if (!isArabic && (result.updateMessageEn?.trim().isNotEmpty ?? false)) {
      return result.updateMessageEn!.trim();
    }

    if (result.forceUpdate) {
      return isArabic
          ? 'يتوفر إصدار جديد من التطبيق. يرجى التحديث للمتابعة.'
          : 'A new app version is available. Please update to continue.';
    }
    return isArabic
        ? 'يتوفر إصدار جديد من التطبيق لتحسين الأداء والاستقرار.'
        : 'A new app version is available with performance and stability improvements.';
  }
}
