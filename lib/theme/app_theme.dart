import 'package:flutter/material.dart';

/// Brand colour shared by every build of the app. Previously hard-coded as
/// `Color(0xff009788)` in ~10 files.
const Color kBrandTeal = Color(0xff009788);

/// Palette values that don't come from [ColorScheme] but were repeated as ad-hoc
/// constants and `isDarkMode ? ... : ...` ternaries across the screens. Pulled
/// onto the [ThemeData] as a [ThemeExtension] so widgets can read
/// `Theme.of(context).extension<AppColors>()!` instead.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brand,
    required this.onBrand,
    required this.screenBackground,
    required this.primaryText,
    required this.invertedText,
    required this.subtitleText,
    required this.outline,
    required this.chipBackground,
    required this.fieldBorder,
    required this.dragSurface,
  });

  /// The teal brand colour (same in both themes).
  final Color brand;

  /// Foreground used on top of [brand] (AppBar titles, FAB icons).
  final Color onBrand;

  final Color screenBackground;
  final Color primaryText;

  /// Text drawn on a brand-coloured surface elsewhere (legacy `altTextColor`).
  final Color invertedText;

  /// De-emphasised text such as the artist line under a song title.
  final Color subtitleText;

  /// Hairline dividers / card outlines.
  final Color outline;

  /// Background of genre [Chip]s.
  final Color chipBackground;

  /// Default border colour for text fields.
  final Color fieldBorder;

  /// Surface shown behind a section while it is being dragged to reorder.
  final Color dragSurface;

  static const AppColors light = AppColors(
    brand: kBrandTeal,
    onBrand: Colors.white,
    screenBackground: Colors.white,
    primaryText: Colors.black,
    invertedText: Colors.white,
    subtitleText: Colors.black,
    outline: Colors.black,
    chipBackground: Color(0xfff4faf8),
    fieldBorder: Color(0xffcccccc),
    dragSurface: Color(0xffe0e0e0),
  );

  static const AppColors dark = AppColors(
    brand: kBrandTeal,
    onBrand: Colors.black,
    screenBackground: Color(0xff171717),
    primaryText: Colors.white,
    invertedText: Colors.black,
    subtitleText: Color(0xff99999e),
    outline: Color(0xff2a2a2a),
    chipBackground: Color(0xff1a1a1a),
    fieldBorder: Colors.white,
    dragSurface: Color(0xff262626),
  );

  @override
  AppColors copyWith({
    Color? brand,
    Color? onBrand,
    Color? screenBackground,
    Color? primaryText,
    Color? invertedText,
    Color? subtitleText,
    Color? outline,
    Color? chipBackground,
    Color? fieldBorder,
    Color? dragSurface,
  }) {
    return AppColors(
      brand: brand ?? this.brand,
      onBrand: onBrand ?? this.onBrand,
      screenBackground: screenBackground ?? this.screenBackground,
      primaryText: primaryText ?? this.primaryText,
      invertedText: invertedText ?? this.invertedText,
      subtitleText: subtitleText ?? this.subtitleText,
      outline: outline ?? this.outline,
      chipBackground: chipBackground ?? this.chipBackground,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      dragSurface: dragSurface ?? this.dragSurface,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brand: Color.lerp(brand, other.brand, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      screenBackground: Color.lerp(screenBackground, other.screenBackground, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      invertedText: Color.lerp(invertedText, other.invertedText, t)!,
      subtitleText: Color.lerp(subtitleText, other.subtitleText, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      fieldBorder: Color.lerp(fieldBorder, other.fieldBorder, t)!,
      dragSurface: Color.lerp(dragSurface, other.dragSurface, t)!,
    );
  }
}

ThemeData _base(Brightness brightness, AppColors appColors) {
  final scheme = ColorScheme.fromSeed(
    seedColor: kBrandTeal,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: appColors.screenBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: kBrandTeal,
      foregroundColor: Colors.white,
    ),
    extensions: [appColors],
  );
}

final ThemeData lightTheme = _base(Brightness.light, AppColors.light);
final ThemeData darkTheme = _base(Brightness.dark, AppColors.dark);

extension AppColorsX on BuildContext {
  /// Shorthand for `Theme.of(this).extension<AppColors>()!`.
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
