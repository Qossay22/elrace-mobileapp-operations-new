import 'package:el_race/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern update popup UI.
///
/// This is intentionally UI-only for now and is not called automatically.
/// Later, it can be triggered from splash after backend version checks.
class AppUpdatePopup extends StatelessWidget {
  const AppUpdatePopup({
    super.key,
    required this.latestVersion,
    this.currentVersion,
    this.isMandatory = false,
    this.onUpdateNow,
    this.onLater,
  });

  final String latestVersion;
  final String? currentVersion;
  final bool isMandatory;
  final VoidCallback? onUpdateNow;
  final VoidCallback? onLater;

  static Future<void> show(
    BuildContext context, {
    required String latestVersion,
    String? currentVersion,
    bool isMandatory = false,
    VoidCallback? onUpdateNow,
    VoidCallback? onLater,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierLabel: 'app_update_popup',
      barrierDismissible: !isMandatory,
      barrierColor: AppThemeColors.pureBlack.withValues(alpha: 0.52),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: AppUpdatePopup(
              latestVersion: latestVersion,
              currentVersion: currentVersion,
              isMandatory: isMandatory,
              onUpdateNow: onUpdateNow,
              onLater: onLater,
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(
      fontSize: 21.sp,
      fontWeight: FontWeight.w800,
      color: AppThemeColors.updateTitle,
      height: 1.15,
    );

    final bodyStyle = GoogleFonts.poppins(
      fontSize: 12.5.sp,
      fontWeight: FontWeight.w500,
      color: AppThemeColors.updateBody,
      height: 1.45,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: 430.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.r),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppThemeColors.surface,
                AppThemeColors.updateSurfaceTint,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppThemeColors.pureBlack.withValues(alpha: 0.14),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: AppThemeColors.brandPrimary.withValues(alpha: 0.09),
                blurRadius: 40,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: AppThemeColors.updateDialogBorder,
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28.r),
            child: Stack(
              children: [
                Positioned(
                  top: -42.h,
                  right: -28.w,
                  child: Container(
                    width: 140.w,
                    height: 140.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppThemeColors.updateErrorGlow,
                          AppThemeColors.transparentError,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -44.w,
                  bottom: -70.h,
                  child: Container(
                    width: 170.w,
                    height: 170.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppThemeColors.updateBrandGlow,
                          AppThemeColors.transparentBrand,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 18.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 54.w,
                            height: 54.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppThemeColors.brandAccent,
                                  AppThemeColors.updateAccent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppThemeColors.brandAccent
                                      .withValues(alpha: 0.34),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.system_update_alt_rounded,
                              color: AppThemeColors.onBrand,
                              size: 28.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Update Available', style: titleStyle),
                                SizedBox(height: 4.h),
                                Text(
                                  'A new version is ready with better speed and stability.',
                                  style: bodyStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _VersionStrip(
                        latestVersion: latestVersion,
                        currentVersion: currentVersion,
                      ),
                      SizedBox(height: 14.h),
                      _HighlightsCard(style: bodyStyle),
                      SizedBox(height: 18.h),
                      _PrimaryActionButton(
                        onTap: () {
                          if (onUpdateNow != null) {
                            onUpdateNow!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      if (!isMandatory) ...[
                        SizedBox(height: 8.h),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              if (onLater != null) {
                                onLater!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppThemeColors.updateLater,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                            ),
                            child: Text(
                              'Later',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionStrip extends StatelessWidget {
  const _VersionStrip({
    required this.latestVersion,
    required this.currentVersion,
  });

  final String latestVersion;
  final String? currentVersion;

  @override
  Widget build(BuildContext context) {
    final tagStyle = GoogleFonts.poppins(
      fontSize: 11.5.sp,
      fontWeight: FontWeight.w700,
      color: AppThemeColors.updateTitle,
    );

    final versionStyle = GoogleFonts.poppins(
      fontSize: 12.5.sp,
      fontWeight: FontWeight.w800,
      color: AppThemeColors.updateTitleStrong,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: AppThemeColors.updatePanel,
        border: Border.all(color: AppThemeColors.updatePanelBorder),
      ),
      child: Row(
        children: [
          _VersionChip(
            label: 'Current',
            value: currentVersion ?? '-',
            tagStyle: tagStyle,
            versionStyle: versionStyle,
            tagBackground: AppThemeColors.updatePanelTag,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: AppThemeColors.updateArrow,
              size: 20.sp,
            ),
          ),
          _VersionChip(
            label: 'Latest',
            value: latestVersion,
            tagStyle: tagStyle.copyWith(color: AppThemeColors.onBrand),
            versionStyle: versionStyle.copyWith(color: AppThemeColors.onBrand),
            tagBackground: AppThemeColors.brandAccent,
          ),
        ],
      ),
    );
  }
}

class _VersionChip extends StatelessWidget {
  const _VersionChip({
    required this.label,
    required this.value,
    required this.tagStyle,
    required this.versionStyle,
    required this.tagBackground,
  });

  final String label;
  final String value;
  final TextStyle tagStyle;
  final TextStyle versionStyle;
  final Color tagBackground;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: tagBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: tagStyle),
            SizedBox(height: 2.h),
            Text(
              value,
              style: versionStyle,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightsCard extends StatelessWidget {
  const _HighlightsCard({required this.style});

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: AppThemeColors.surface,
        border: Border.all(color: AppThemeColors.updateCardBorder),
      ),
      child: Column(
        children: [
          _UpdatePoint(
            text: 'Improved app performance and smoother navigation.',
            style: style,
          ),
          SizedBox(height: 7.h),
          _UpdatePoint(
            text: 'Important bug fixes and stability improvements.',
            style: style,
          ),
          SizedBox(height: 7.h),
          _UpdatePoint(
            text: 'Security patches to keep your data protected.',
            style: style,
          ),
        ],
      ),
    );
  }
}

class _UpdatePoint extends StatelessWidget {
  const _UpdatePoint({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 3.h),
          child: Container(
            width: 7.w,
            height: 7.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppThemeColors.brandAccent,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Ink(
          height: 52.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppThemeColors.brandAccent,
                AppThemeColors.updateAccent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppThemeColors.brandAccent.withValues(alpha: 0.34),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_rounded,
                  color: AppThemeColors.onBrand,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Update Now',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.onBrand,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
