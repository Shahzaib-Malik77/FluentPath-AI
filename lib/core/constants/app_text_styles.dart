import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String _fontFamily = 'Merienda';

  static const heading1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold,   color: AppColors.textWhite, fontFamily: _fontFamily);
  static const heading2 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold,   color: AppColors.textWhite, fontFamily: _fontFamily);
  static const heading3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600,   color: AppColors.textWhite, fontFamily: _fontFamily);
  static const body     = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textBeige, fontFamily: _fontFamily);
  static const bodyDark = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textDark, fontFamily: _fontFamily);
  static const caption  = TextStyle(fontSize: 12, fontWeight: FontWeight.w400,   color: AppColors.textMuted, fontFamily: _fontFamily);
  static const button   = TextStyle(fontSize: 16, fontWeight: FontWeight.w600,   color: AppColors.textWhite, fontFamily: _fontFamily);
  static const wordTitle= TextStyle(fontSize: 32, fontWeight: FontWeight.bold,   color: AppColors.textDark, fontFamily: _fontFamily);
}
