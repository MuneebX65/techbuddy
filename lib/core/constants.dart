import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Main Colors
  static const primary = Color(0xFF1B6B4A);
  static const secondary = Color(0xFF2D9E6B);
  static const accent = Color(0xFF1D4ED8);
  static const light = Color(0xFF5DD49A);

  // Backgrounds
  static const background = Color(0xFFF5F0E8);
  static const cardBg = Colors.white;

  // Text
  static const textDark = Color(0xFF1F2937);
  static const textMuted = Color(0xFF6B7280);

  // Result Colors
  static const successBg = Color(0xFFE8F5EE);
  static const successText = Color(0xFF1B6B4A);
  static const dangerBg = Color(0xFFFEE2E2);
  static const dangerText = Color(0xFF991B1B);

  // Lesson Card Colors
  static const lessonGreen = Color(0xFFE8F5EE);
  static const lessonAmber = Color(0xFFFEF3C7);
  static const lessonBlue = Color(0xFFDBEAFE);
  static const lessonRed = Color(0xFFFEE2E2);
  static const lessonPurple = Color(0xFFEDE9FE);
}

class AppSizes {
  static const double heading = 28.0;
  static const double body = 18.0;
  static const double button = 20.0;
  static const double buttonHeight = 72.0;
  static const double radius = 16.0;
  static const double padding = 20.0;
  static const double maxWidth = 480.0;
}

class AppStrings {
  static const appName = 'TechBuddy';
  static const tagline = 'Your friendly tech helper';
}

class AppTextStyles {
  static TextTheme appTextTheme = GoogleFonts.nunitoTextTheme();

  // Headings — Nunito
  static TextStyle pageTitle = GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle sectionTitle = GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle cardTitle = GoogleFonts.nunito(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle buttonText = GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle appBarSubtitle = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
  );

  // Body — Inter
  static TextStyle body = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.6,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static TextStyle badge = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle stepInstruction = GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.6,
  );

  static TextStyle chatBubble = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle hint = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
