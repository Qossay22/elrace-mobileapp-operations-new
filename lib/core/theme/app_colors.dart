import 'package:flutter/material.dart';

/// App-wide color tokens shared by cross-feature UI.
///
/// Feature-specific palettes such as HR and Timesheet can keep their own
/// module files under `core/theme`. This file is the neutral place for brand,
/// text, surface, feedback, and startup colors that are reused across modules.
class AppThemeColors {
  const AppThemeColors._();

  static const Color brandPrimary = Color(0xFF1A1A53);
  static const Color brandAccent = Color(0xFFBA1719);
  static const Color brandBlue = Color(0xFF101096);
  static const Color reportBlue = Color(0xFF2B2C74);
  static const Color reportMaroon = Color(0xFFCC2B2F);
  static const Color reportModuleMaroon = Color(0xFF161B54);

  static const Color splashBackground = Color(0xFF000000);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF2F2F2);
  static const Color softWhite = Color(0xFFFAFBFA);
  static const Color lightGrey = Color(0xFFF8F8F8);
  static const Color darkGrey = Color(0xFFD0D0D0);
  static const Color reportContainer = Color(0xFFECECF2);
  static const Color textPrimary = Color(0xFF1F2430);
  static const Color textSecondary = Color(0xFF55596A);
  static const Color textTertiary = Color(0xFF747789);
  static const Color legacyInk = Color(0xFF000124);
  static const Color legacyGreyText = Color(0xFF969697);
  static const Color legacyGreyText2 = Color(0xFFD6D6D6);
  static const Color legacyGreyText3 = Color(0xFFCECDCD);

  static const Color error = brandAccent;
  static const Color errorContainer = Color(0xFFFFEFEF);
  static const Color errorBorder = Color(0xFFFFD7D8);
  static const Color updateAccent = Color(0xFFD43A3C);
  static const Color updateTitle = Color(0xFF141430);
  static const Color updateTitleStrong = Color(0xFF121228);
  static const Color updateBody = Color(0xFF4E4E62);
  static const Color updateLater = Color(0xFF4F4F63);
  static const Color updateArrow = Color(0xFF7A80A7);
  static const Color updateSurfaceTint = Color(0xFFF8F9FF);
  static const Color updatePanel = Color(0xFFF2F4FF);
  static const Color updatePanelTag = Color(0xFFE9ECFF);
  static const Color updatePanelBorder = Color(0xFFDFE5FF);
  static const Color updateCardBorder = Color(0xFFEAEAEA);
  static const Color updateDialogBorder = Color(0xFFE8EBFF);
  static const Color updateBrandGlow = Color(0x241A1A53);
  static const Color updateErrorGlow = Color(0x44BA1719);
  static const Color transparentBrand = Color(0x001A1A53);
  static const Color transparentError = Color(0x00BA1719);
  static const Color legacyRed = brandAccent;
  static const Color darkPeach = Color(0xFFFFC9B3);
  static const Color lightPeach = Color(0xFFFFD2C2);
  static const Color buttonDark = Color(0xFF685C82);
  static const Color buttonLight = Color(0xFFD1D1FF);
  static const Color shadowBlueDark = Color(0xFF151544);
  static const Color shadowBlueLight = Color(0xFF3535AA);

  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);
  static const Color reportLightBlack = Color(0xCC000000);
}
