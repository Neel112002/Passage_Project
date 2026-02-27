import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  // Spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Edge insets shortcuts
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

/// Border radius constants for consistent rounded corners
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

// =============================================================================
// TEXT STYLE EXTENSIONS
// =============================================================================

/// Extension to add text style utilities to BuildContext
/// Access via context.textStyles
extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

/// Helper methods for common text style modifications
extension TextStyleExtensions on TextStyle {
  /// Make text bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Make text semi-bold
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Make text medium weight
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Make text normal weight
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);

  /// Make text light
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// Add custom color
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Add custom size
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

// =============================================================================
// COLORS
// =============================================================================

/// App brand colors
class BrandColors {
  // Deep navy primary
  static const Color navy = Color(0xFF0B1B3B);
  // Warm orange accent
  static const Color orange = Color(0xFFFF8A3D);
  // Light beige background for light mode
  static const Color beige = Color(0xFFFAF6F1);
}

/// Modern, neutral color palette for light mode (navy + orange)
class LightModeColors {
  static const lightPrimary = BrandColors.navy;
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFF1D2C52);
  static const lightOnPrimaryContainer = Color(0xFFCCD6EE);

  // Secondary/Accent: Warm orange
  static const lightSecondary = BrandColors.orange;
  static const lightOnSecondary = Color(0xFF1E1E1E);
  static const lightSecondaryContainer = Color(0xFFFFE3D1);
  static const lightOnSecondaryContainer = Color(0xFF5A2A00);

  // Tertiary: Muted slate for subtle accents
  static const lightTertiary = Color(0xFF5C6B7A);
  static const lightOnTertiary = Color(0xFFFFFFFF);

  // Error colors
  static const lightError = Color(0xFFBA1A1A);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF410002);

  // Surface and background
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOnSurface = Color(0xFF1A1C1E);
  static const lightBackground = BrandColors.beige; // soft neutral background
  static const lightSurfaceVariant = Color(0xFFEAECEF);
  static const lightOnSurfaceVariant = Color(0xFF454B51);

  // Outline and shadow
  static const lightOutline = Color(0xFF7C8288);
  static const lightShadow = Color(0xFF000000);
  static const lightInversePrimary = Color(0xFF9FB3D9);
}

/// Dark mode colors with good contrast
class DarkModeColors {
  static const darkPrimary = Color(0xFF9FB3D9);
  static const darkOnPrimary = Color(0xFF0C1A34);
  static const darkPrimaryContainer = Color(0xFF2A3A5E);
  static const darkOnPrimaryContainer = Color(0xFFD7E2FA);

  // Secondary: warm orange adjusted for dark
  static const darkSecondary = Color(0xFFFFB284);
  static const darkOnSecondary = Color(0xFF2A1900);
  static const darkSecondaryContainer = Color(0xFF5A2A00);
  static const darkOnSecondaryContainer = Color(0xFFFFE3D1);

  // Tertiary
  static const darkTertiary = Color(0xFFB0BCC8);
  static const darkOnTertiary = Color(0xFF26313A);

  // Error colors
  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);

  // Surface and background: True dark mode
  static const darkSurface = Color(0xFF0F1115);
  static const darkOnSurface = Color(0xFFE5E7EB);
  static const darkSurfaceVariant = Color(0xFF31343A);
  static const darkOnSurfaceVariant = Color(0xFFC6CBD1);

  // Outline and shadow
  static const darkOutline = Color(0xFF8E9099);
  static const darkShadow = Color(0xFF000000);
  static const darkInversePrimary = Color(0xFF2E436C);
}

/// Font size constants
class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

// =============================================================================
// THEMES
// =============================================================================

/// Shared rounded shape for buttons
OutlinedBorder _roundedButtonShape() => RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg));

/// Light theme with modern, minimal aesthetic
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: LightModeColors.lightPrimary,
    onPrimary: LightModeColors.lightOnPrimary,
    primaryContainer: LightModeColors.lightPrimaryContainer,
    onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
    secondary: LightModeColors.lightSecondary,
    onSecondary: LightModeColors.lightOnSecondary,
    secondaryContainer: LightModeColors.lightSecondaryContainer,
    onSecondaryContainer: LightModeColors.lightOnSecondaryContainer,
    tertiary: LightModeColors.lightTertiary,
    onTertiary: LightModeColors.lightOnTertiary,
    error: LightModeColors.lightError,
    onError: LightModeColors.lightOnError,
    errorContainer: LightModeColors.lightErrorContainer,
    onErrorContainer: LightModeColors.lightOnErrorContainer,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
    surfaceContainerHighest: LightModeColors.lightSurfaceVariant,
    onSurfaceVariant: LightModeColors.lightOnSurfaceVariant,
    outline: LightModeColors.lightOutline,
    shadow: LightModeColors.lightShadow,
    inversePrimary: LightModeColors.lightInversePrimary,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: LightModeColors.lightBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: LightModeColors.lightOnSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: LightModeColors.lightOutline.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
  ),
  textTheme: _buildTextTheme(Brightness.light),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(_roundedButtonShape()),
      backgroundColor: const MaterialStatePropertyAll(LightModeColors.lightPrimary),
      foregroundColor: const MaterialStatePropertyAll(LightModeColors.lightOnPrimary),
      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
      textStyle: MaterialStatePropertyAll(GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(_roundedButtonShape()),
      backgroundColor: const MaterialStatePropertyAll(LightModeColors.lightSecondary),
      foregroundColor: const MaterialStatePropertyAll(LightModeColors.lightOnSecondary),
      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
      textStyle: MaterialStatePropertyAll(GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(_roundedButtonShape()),
      side: MaterialStatePropertyAll(BorderSide(color: LightModeColors.lightOutline.withValues(alpha: 0.5), width: 1)),
      foregroundColor: const MaterialStatePropertyAll(LightModeColors.lightPrimary),
      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
      textStyle: MaterialStatePropertyAll(GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const MaterialStatePropertyAll(LightModeColors.lightPrimary),
      iconColor: const MaterialStatePropertyAll(LightModeColors.lightPrimary),
      overlayColor: MaterialStatePropertyAll(LightModeColors.lightPrimary.withValues(alpha: 0.08)),
      shape: MaterialStatePropertyAll(_roundedButtonShape()),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: LightModeColors.lightSecondary,
    foregroundColor: LightModeColors.lightOnSecondary,
    shape: StadiumBorder(),
  ),
);

/// Dark theme with good contrast and readability
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: DarkModeColors.darkPrimary,
    onPrimary: DarkModeColors.darkOnPrimary,
    primaryContainer: DarkModeColors.darkPrimaryContainer,
    onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
    secondary: DarkModeColors.darkSecondary,
    onSecondary: DarkModeColors.darkOnSecondary,
    secondaryContainer: DarkModeColors.darkSecondaryContainer,
    onSecondaryContainer: DarkModeColors.darkOnSecondaryContainer,
    tertiary: DarkModeColors.darkTertiary,
    onTertiary: DarkModeColors.darkOnTertiary,
    error: DarkModeColors.darkError,
    onError: DarkModeColors.darkOnError,
    errorContainer: DarkModeColors.darkErrorContainer,
    onErrorContainer: DarkModeColors.darkOnErrorContainer,
    surface: DarkModeColors.darkSurface,
    onSurface: DarkModeColors.darkOnSurface,
    surfaceContainerHighest: DarkModeColors.darkSurfaceVariant,
    onSurfaceVariant: DarkModeColors.darkOnSurfaceVariant,
    outline: DarkModeColors.darkOutline,
    shadow: DarkModeColors.darkShadow,
    inversePrimary: DarkModeColors.darkInversePrimary,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: DarkModeColors.darkSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: DarkModeColors.darkOnSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: DarkModeColors.darkOutline.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
  ),
  textTheme: _buildTextTheme(Brightness.dark),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(_roundedButtonShape()),
      backgroundColor: const MaterialStatePropertyAll(DarkModeColors.darkPrimary),
      foregroundColor: const MaterialStatePropertyAll(DarkModeColors.darkOnPrimary),
      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
      textStyle: MaterialStatePropertyAll(GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(_roundedButtonShape()),
      backgroundColor: const MaterialStatePropertyAll(DarkModeColors.darkSecondary),
      foregroundColor: const MaterialStatePropertyAll(DarkModeColors.darkOnSecondary),
      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
      textStyle: MaterialStatePropertyAll(GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(_roundedButtonShape()),
      side: MaterialStatePropertyAll(BorderSide(color: DarkModeColors.darkOutline.withValues(alpha: 0.5), width: 1)),
      foregroundColor: const MaterialStatePropertyAll(DarkModeColors.darkPrimary),
      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
      textStyle: MaterialStatePropertyAll(GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const MaterialStatePropertyAll(DarkModeColors.darkPrimary),
      iconColor: const MaterialStatePropertyAll(DarkModeColors.darkPrimary),
      overlayColor: MaterialStatePropertyAll(DarkModeColors.darkPrimary.withValues(alpha: 0.12)),
      shape: MaterialStatePropertyAll(_roundedButtonShape()),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: DarkModeColors.darkSecondary,
    foregroundColor: DarkModeColors.darkOnSecondary,
    shape: StadiumBorder(),
  ),
);

/// Build text theme using Inter font family
TextTheme _buildTextTheme(Brightness brightness) {
  return TextTheme(
    displayLarge: GoogleFonts.inter(fontSize: FontSizes.displayLarge, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    displayMedium: GoogleFonts.inter(fontSize: FontSizes.displayMedium, fontWeight: FontWeight.w400),
    displaySmall: GoogleFonts.inter(fontSize: FontSizes.displaySmall, fontWeight: FontWeight.w400),
    headlineLarge: GoogleFonts.inter(fontSize: FontSizes.headlineLarge, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    headlineMedium: GoogleFonts.inter(fontSize: FontSizes.headlineMedium, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.inter(fontSize: FontSizes.headlineSmall, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.inter(fontSize: FontSizes.titleLarge, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.inter(fontSize: FontSizes.titleMedium, fontWeight: FontWeight.w500),
    titleSmall: GoogleFonts.inter(fontSize: FontSizes.titleSmall, fontWeight: FontWeight.w500),
    labelLarge: GoogleFonts.inter(fontSize: FontSizes.labelLarge, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    labelMedium: GoogleFonts.inter(fontSize: FontSizes.labelMedium, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    labelSmall: GoogleFonts.inter(fontSize: FontSizes.labelSmall, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    bodyLarge: GoogleFonts.inter(fontSize: FontSizes.bodyLarge, fontWeight: FontWeight.w400, letterSpacing: 0.15),
    bodyMedium: GoogleFonts.inter(fontSize: FontSizes.bodyMedium, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    bodySmall: GoogleFonts.inter(fontSize: FontSizes.bodySmall, fontWeight: FontWeight.w400, letterSpacing: 0.4),
  );
}
