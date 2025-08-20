import 'package:flutter/material.dart';

class AppTheme {
  static const Color white = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF6B7280);
  static const Color green1 = Color(0xFF166534);
  static const Color buttonGreen = Color(0xFF22C55E);
  static const Color black = Color(0xFF000000);
  static const Color gray1 = Color(0xFFE5E7EB);
  static const Color gray2 = Color(0xFF9CA3AF);
  static const Color lightGray1 = Color(0xFFF9FAFB);
  static const Color lightGreen1 = Color(0xFFF0F9F0);
  static const Color lightGreen2 = Color(0xFFE8F5E8);
  static const Color green2 = Color(0xFF16A34A);
  static const Color buttonTextColor = Color(0xFF374151);
  static const Color gray3 = Color(0xFF757575);
  static const Color appBarBorder = Color(0xFFE2E8F0);
  static const Color lightGray2 = Color(0xFFF3F4F6);
  static const Color appBarBackground = white;
  
  // Font Sizes
  static const double fontSizeXS = 12.0;
  static const double fontSizeSM = 14.0;
  static const double fontSizeBase = 16.0;
  static const double fontSizeLG = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSize2XL = 24.0;
  static const double fontSize3XL = 30.0;
  static const double fontSize4XL = 36.0;
  static const double fontSize5XL = 48.0;
  
  // Line Heights
  static const double lineHeightTight = 1.25;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.625;
  
  // Font Weights
  static const FontWeight fontWeightThin = FontWeight.w100;
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;
  
  // Text themes
  static const TextStyle headingLarge = TextStyle(
    fontSize: fontSize4XL,
    fontWeight: fontWeightBold,
    height: lineHeightTight,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: fontSize3XL,
    fontWeight: fontWeightSemiBold,
    height: lineHeightTight,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: fontSize2XL,
    fontWeight: fontWeightSemiBold,
    height: lineHeightNormal,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: fontSizeXL,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: fontSizeLG,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: fontSizeBase,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: fontSizeLG,
    fontWeight: fontWeightNormal,
    height: lineHeightRelaxed,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeBase,
    fontWeight: fontWeightNormal,
    height: lineHeightNormal,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: fontWeightNormal,
    height: lineHeightNormal,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: fontSizeBase,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: fontSizeXS,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: fontSizeBase,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: fontSizeXS,
    fontWeight: fontWeightNormal,
    height: lineHeightNormal,
  );
  
  static LinearGradient get homePageGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightGreen1, lightGreen2, lightGreen1], 
    stops: [0.0, 0.5, 1.0],
  );
  
  static LinearGradient get cardGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen1, lightGreen2], 
  );
  
  static LinearGradient get buttonGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [buttonGreen, green2], 
  );

  // Appbar theme  
  static const AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: appBarBackground,
    elevation: 1,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontSize: fontSizeXL,
      fontWeight: fontWeightSemiBold,
      color: black,
    ),
    iconTheme: IconThemeData(
      color: black,
      size: 24,
    ),
    shape: Border(
      bottom: BorderSide(
        color: appBarBorder,
        width: 1.0,
      ),
    ),
  );
  
}