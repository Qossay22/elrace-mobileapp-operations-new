import 'package:el_race/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextStyle {
  static TextStyle heading = GoogleFonts.poppins().copyWith(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppThemeColors.surface);
  static TextStyle reportTitle = GoogleFonts.poppins().copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppThemeColors.pureBlack);
  static TextStyle reportHeader = GoogleFonts.poppins().copyWith(
      fontSize: 12, fontWeight: FontWeight.w600, color: AppThemeColors.surface);
  static TextStyle smallGrey = GoogleFonts.poppins().copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppThemeColors.reportLightBlack);
  static TextStyle smallWhite = GoogleFonts.poppins().copyWith(
      fontSize: 10, fontWeight: FontWeight.w600, color: AppThemeColors.surface);
}
