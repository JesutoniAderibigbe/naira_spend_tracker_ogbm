// Theme for Naira Spend Tracker.
//
// Light values come from design-tokens.tokens.json (Figma Design Tokens
// plugin). The tokens file has no dark values, so dark mode is derived with
// ColorScheme.fromSeed: the main scheme from `primary`, and status and
// category colours from their own light token used as a seed.
//
// This is the only place under lib/ui allowed to declare Color(0x...).
// Widgets read colours from Theme.of(context) and its extensions.

import 'package:flutter/material.dart';

/// Raw colour tokens, named after design-tokens.tokens.json (`colour/...`).
abstract final class AppTokens {
  // Core.
  static const primary = Color(0xFF008751);
  static const primaryText = Color(0xFF006B40);
  static const ink = Color(0xFF14201A);
  static const surface = Color(0xFFF7F9F7);
  static const container = Color(0xFFE3F1E8);
  static const muted = Color(0xFF4E5D55);
  static const warning = Color(0xFFD98B00);
  static const danger = Color(0xFFC0392B);

  // Support.
  static const white = Color(0xFFFFFFFF);
  static const bodyText = Color(0xFF3E4B44);
  static const border = Color(0xFFDCE5DF);
  static const borderStrong = Color(0xFFB8C6BD);
  static const divider = Color(0xFFEEF2EF);
  static const track = Color(0xFFEEF2EF);
  static const segmentBg = Color(0xFFE8EEEA);
  static const chartMuted = Color(0xFF9CCBB0);
  static const chartFaint = Color(0xFFB9D9C6);
  static const primaryTrack = Color(0xFFD5E9DC);
  static const warningTrack = Color(0xFFF7E6C2);
  static const warningText = Color(0xFF7A4A00);
  static const warningBg = Color(0xFFFFF6E0);
  static const warningBorder = Color(0xFFF2D58F);
  static const warningInk = Color(0xFF5A3700);
  static const dangerTrack = Color(0xFFF3D3CE);
  static const dangerText = Color(0xFFA3271A);
  static const dangerInk = Color(0xFF7A1D13);
  static const dangerBg = Color(0xFFFDECEA);
  static const dangerBorder = Color(0xFFF1B2AA);

  // Category.
  static const foodBg = Color(0xFFFDEFD2);
  static const foodFg = Color(0xFF7A4A00);
  static const transportBg = Color(0xFFE1ECFB);
  static const transportFg = Color(0xFF1D4F91);
  static const dataBg = Color(0xFFEAE3FA);
  static const dataFg = Color(0xFF4B2A99);
  static const billsBg = Color(0xFFFDE7E4);
  static const billsFg = Color(0xFFA3271A);
  static const funBg = Color(0xFFFCE4F1);
  static const funFg = Color(0xFF8E1F5B);
  static const otherBg = Color(0xFFE8EEEA);
  static const otherFg = Color(0xFF3E4B44);
}

/// Text style tokens (`font/...`). No colour is set, so text picks up the
/// ambient DefaultTextStyle colour. Height is lineHeight / fontSize.
///
/// Sora and Manrope are not bundled yet; until they are, Flutter falls back
/// to the platform font.
abstract final class AppTextStyles {
  static const _sora = 'Sora';
  static const _manrope = 'Manrope';

  // Headings.
  static const display = TextStyle(
    fontFamily: _sora,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 43.2 / 40,
    letterSpacing: -0.8,
  );
  static const h1 = TextStyle(
    fontFamily: _sora,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 33.6 / 28,
  );
  static const h2 = TextStyle(
    fontFamily: _sora,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 28.8 / 24,
  );
  static const h3 = TextStyle(
    fontFamily: _sora,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 24 / 20,
  );
  static const monogram = TextStyle(
    fontFamily: _sora,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 19.2 / 16,
  );

  // Amounts.
  static const amountHero = TextStyle(
    fontFamily: _sora,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 48 / 40,
  );
  static const amountLarge = TextStyle(
    fontFamily: _sora,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 43.2 / 36,
    letterSpacing: -0.72,
  );
  static const amountMedium = TextStyle(
    fontFamily: _sora,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 40.8 / 34,
    letterSpacing: -0.68,
  );
  static const amountSmall = TextStyle(
    fontFamily: _sora,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 26.4 / 22,
  );
  static const amountRow = TextStyle(
    fontFamily: _sora,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 18 / 15,
  );

  // Body.
  static const bodyLarge = TextStyle(
    fontFamily: _manrope,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 27 / 18,
  );
  static const button = TextStyle(
    fontFamily: _manrope,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 20.4 / 17,
  );
  static const title = TextStyle(
    fontFamily: _manrope,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 19.2 / 16,
  );
  static const body = TextStyle(
    fontFamily: _manrope,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 19.2 / 16,
  );
  static const bodyMedium = TextStyle(
    fontFamily: _manrope,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 19.2 / 16,
  );
  static const bodyStrong = TextStyle(
    fontFamily: _manrope,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 18 / 15,
  );
  static const small = TextStyle(
    fontFamily: _manrope,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20.3 / 14,
  );
  static const smallMedium = TextStyle(
    fontFamily: _manrope,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 16.8 / 14,
  );
  static const smallStrong = TextStyle(
    fontFamily: _manrope,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 16.8 / 14,
  );
  static const caption = TextStyle(
    fontFamily: _manrope,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 19.5 / 13,
  );
  static const captionStrong = TextStyle(
    fontFamily: _manrope,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 15.6 / 13,
  );
  static const tiny = TextStyle(
    fontFamily: _manrope,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 14.4 / 12,
  );
  static const tinyStrong = TextStyle(
    fontFamily: _manrope,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 14.4 / 12,
  );

  /// Material roles mapped to the closest token. Amount, monogram and the
  /// medium/strong variants have no Material role; use them directly.
  static const textTheme = TextTheme(
    displayLarge: display,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge: title,
    titleMedium: bodyStrong,
    titleSmall: smallStrong,
    bodyLarge: bodyLarge,
    bodyMedium: body,
    bodySmall: small,
    labelLarge: button,
    labelMedium: captionStrong,
    labelSmall: tiny,
  );
}

/// Colours for a progress bar and its label.
@immutable
class BudgetStatusStyle {
  const BudgetStatusStyle({
    required this.bar,
    required this.track,
    required this.text,
  });

  final Color bar;
  final Color track;
  final Color text;

  static BudgetStatusStyle lerp(
    BudgetStatusStyle a,
    BudgetStatusStyle b,
    double t,
  ) {
    return BudgetStatusStyle(
      bar: Color.lerp(a.bar, b.bar, t)!,
      track: Color.lerp(a.track, b.track, t)!,
      text: Color.lerp(a.text, b.text, t)!,
    );
  }
}

/// Budget bar colours by how much of the limit is spent.
///
/// The tokens have no separate "at limit" colour, so [atLimit] uses the
/// warning colours, like [near]; the full bar is what tells them apart.
@immutable
class BudgetStatusColors extends ThemeExtension<BudgetStatusColors> {
  const BudgetStatusColors({
    required this.fine,
    required this.near,
    required this.atLimit,
    required this.over,
  });

  final BudgetStatusStyle fine;
  final BudgetStatusStyle near;
  final BudgetStatusStyle atLimit;
  final BudgetStatusStyle over;

  static BudgetStatusColors of(BuildContext context) =>
      Theme.of(context).extension<BudgetStatusColors>()!;

  static const light = BudgetStatusColors(
    fine: BudgetStatusStyle(
      bar: AppTokens.primary,
      track: AppTokens.primaryTrack,
      text: AppTokens.primaryText,
    ),
    near: BudgetStatusStyle(
      bar: AppTokens.warning,
      track: AppTokens.warningTrack,
      text: AppTokens.warningText,
    ),
    atLimit: BudgetStatusStyle(
      bar: AppTokens.warning,
      track: AppTokens.warningTrack,
      text: AppTokens.warningText,
    ),
    over: BudgetStatusStyle(
      bar: AppTokens.danger,
      track: AppTokens.dangerTrack,
      text: AppTokens.dangerText,
    ),
  );

  static BudgetStatusColors dark(AppPalette palette, ColorScheme scheme) {
    final warning = BudgetStatusStyle(
      bar: palette.warning,
      track: palette.warningTrack,
      text: palette.warningText,
    );
    return BudgetStatusColors(
      fine: BudgetStatusStyle(
        bar: scheme.primary,
        track: palette.primaryTrack,
        text: scheme.primary,
      ),
      near: warning,
      atLimit: warning,
      over: BudgetStatusStyle(
        bar: palette.danger,
        track: palette.dangerTrack,
        text: palette.dangerText,
      ),
    );
  }

  @override
  BudgetStatusColors copyWith({
    BudgetStatusStyle? fine,
    BudgetStatusStyle? near,
    BudgetStatusStyle? atLimit,
    BudgetStatusStyle? over,
  }) {
    return BudgetStatusColors(
      fine: fine ?? this.fine,
      near: near ?? this.near,
      atLimit: atLimit ?? this.atLimit,
      over: over ?? this.over,
    );
  }

  @override
  BudgetStatusColors lerp(BudgetStatusColors? other, double t) {
    if (other == null) return this;
    return BudgetStatusColors(
      fine: BudgetStatusStyle.lerp(fine, other.fine, t),
      near: BudgetStatusStyle.lerp(near, other.near, t),
      atLimit: BudgetStatusStyle.lerp(atLimit, other.atLimit, t),
      over: BudgetStatusStyle.lerp(over, other.over, t),
    );
  }
}

/// Background and foreground for a category icon tile.
@immutable
class CategoryColors {
  const CategoryColors({required this.bg, required this.fg});

  final Color bg;
  final Color fg;

  /// Dark pair derived from the light foreground token as a seed.
  factory CategoryColors.darkFrom(Color lightFg) {
    final scheme = _darkSchemeFrom(lightFg);
    return CategoryColors(
      bg: scheme.primaryContainer,
      fg: scheme.onPrimaryContainer,
    );
  }

  static CategoryColors lerp(CategoryColors a, CategoryColors b, double t) {
    return CategoryColors(
      bg: Color.lerp(a.bg, b.bg, t)!,
      fg: Color.lerp(a.fg, b.fg, t)!,
    );
  }
}

ColorScheme _darkSchemeFrom(Color seed) =>
    ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);

/// Token colours that have no ColorScheme role: support, warning, danger,
/// chart and category colours.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.card,
    required this.bodyText,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.track,
    required this.segmentBg,
    required this.chartMuted,
    required this.chartFaint,
    required this.primaryTrack,
    required this.warning,
    required this.warningTrack,
    required this.warningText,
    required this.warningBg,
    required this.warningBorder,
    required this.warningInk,
    required this.danger,
    required this.dangerTrack,
    required this.dangerText,
    required this.dangerInk,
    required this.dangerBg,
    required this.dangerBorder,
    required this.food,
    required this.transport,
    required this.data,
    required this.bills,
    required this.fun,
    required this.other,
  });

  /// Card and sheet background (`support/white` in light mode).
  final Color card;
  final Color bodyText;
  final Color border;
  final Color borderStrong;
  final Color divider;
  final Color track;
  final Color segmentBg;
  final Color chartMuted;
  final Color chartFaint;
  final Color primaryTrack;
  final Color warning;
  final Color warningTrack;
  final Color warningText;
  final Color warningBg;
  final Color warningBorder;
  final Color warningInk;
  final Color danger;
  final Color dangerTrack;
  final Color dangerText;
  final Color dangerInk;
  final Color dangerBg;
  final Color dangerBorder;
  final CategoryColors food;
  final CategoryColors transport;
  final CategoryColors data;
  final CategoryColors bills;
  final CategoryColors fun;
  final CategoryColors other;

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>()!;

  static const light = AppPalette(
    card: AppTokens.white,
    bodyText: AppTokens.bodyText,
    border: AppTokens.border,
    borderStrong: AppTokens.borderStrong,
    divider: AppTokens.divider,
    track: AppTokens.track,
    segmentBg: AppTokens.segmentBg,
    chartMuted: AppTokens.chartMuted,
    chartFaint: AppTokens.chartFaint,
    primaryTrack: AppTokens.primaryTrack,
    warning: AppTokens.warning,
    warningTrack: AppTokens.warningTrack,
    warningText: AppTokens.warningText,
    warningBg: AppTokens.warningBg,
    warningBorder: AppTokens.warningBorder,
    warningInk: AppTokens.warningInk,
    danger: AppTokens.danger,
    dangerTrack: AppTokens.dangerTrack,
    dangerText: AppTokens.dangerText,
    dangerInk: AppTokens.dangerInk,
    dangerBg: AppTokens.dangerBg,
    dangerBorder: AppTokens.dangerBorder,
    food: CategoryColors(bg: AppTokens.foodBg, fg: AppTokens.foodFg),
    transport: CategoryColors(
      bg: AppTokens.transportBg,
      fg: AppTokens.transportFg,
    ),
    data: CategoryColors(bg: AppTokens.dataBg, fg: AppTokens.dataFg),
    bills: CategoryColors(bg: AppTokens.billsBg, fg: AppTokens.billsFg),
    fun: CategoryColors(bg: AppTokens.funBg, fg: AppTokens.funFg),
    other: CategoryColors(bg: AppTokens.otherBg, fg: AppTokens.otherFg),
  );

  /// Derived: neutrals and chart colours from the dark primary [scheme];
  /// warning and danger from fromSeed schemes seeded with their tokens.
  factory AppPalette.dark(ColorScheme scheme) {
    final warning = _darkSchemeFrom(AppTokens.warning);
    final danger = _darkSchemeFrom(AppTokens.danger);
    return AppPalette(
      card: scheme.surfaceContainerLow,
      bodyText: scheme.onSurfaceVariant,
      border: scheme.outlineVariant,
      borderStrong: scheme.outline,
      divider: scheme.surfaceContainerHighest,
      track: scheme.surfaceContainerHighest,
      segmentBg: scheme.surfaceContainerHigh,
      chartMuted: scheme.primaryContainer,
      chartFaint: scheme.surfaceContainerHighest,
      primaryTrack: scheme.surfaceContainerHighest,
      warning: warning.primary,
      warningTrack: warning.primaryContainer,
      warningText: warning.primary,
      warningBg: warning.primaryContainer,
      warningBorder: warning.outlineVariant,
      warningInk: warning.onPrimaryContainer,
      danger: danger.primary,
      dangerTrack: danger.primaryContainer,
      dangerText: danger.primary,
      dangerInk: danger.onPrimaryContainer,
      dangerBg: danger.primaryContainer,
      dangerBorder: danger.outlineVariant,
      food: CategoryColors.darkFrom(AppTokens.foodFg),
      transport: CategoryColors.darkFrom(AppTokens.transportFg),
      data: CategoryColors.darkFrom(AppTokens.dataFg),
      bills: CategoryColors.darkFrom(AppTokens.billsFg),
      fun: CategoryColors.darkFrom(AppTokens.funFg),
      // Other is neutral (segment-bg / body-text in light); seeding it
      // would turn it green, so it follows the neutrals instead.
      other: CategoryColors(
        bg: scheme.surfaceContainerHigh,
        fg: scheme.onSurfaceVariant,
      ),
    );
  }

  @override
  AppPalette copyWith({
    Color? card,
    Color? bodyText,
    Color? border,
    Color? borderStrong,
    Color? divider,
    Color? track,
    Color? segmentBg,
    Color? chartMuted,
    Color? chartFaint,
    Color? primaryTrack,
    Color? warning,
    Color? warningTrack,
    Color? warningText,
    Color? warningBg,
    Color? warningBorder,
    Color? warningInk,
    Color? danger,
    Color? dangerTrack,
    Color? dangerText,
    Color? dangerInk,
    Color? dangerBg,
    Color? dangerBorder,
    CategoryColors? food,
    CategoryColors? transport,
    CategoryColors? data,
    CategoryColors? bills,
    CategoryColors? fun,
    CategoryColors? other,
  }) {
    return AppPalette(
      card: card ?? this.card,
      bodyText: bodyText ?? this.bodyText,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      track: track ?? this.track,
      segmentBg: segmentBg ?? this.segmentBg,
      chartMuted: chartMuted ?? this.chartMuted,
      chartFaint: chartFaint ?? this.chartFaint,
      primaryTrack: primaryTrack ?? this.primaryTrack,
      warning: warning ?? this.warning,
      warningTrack: warningTrack ?? this.warningTrack,
      warningText: warningText ?? this.warningText,
      warningBg: warningBg ?? this.warningBg,
      warningBorder: warningBorder ?? this.warningBorder,
      warningInk: warningInk ?? this.warningInk,
      danger: danger ?? this.danger,
      dangerTrack: dangerTrack ?? this.dangerTrack,
      dangerText: dangerText ?? this.dangerText,
      dangerInk: dangerInk ?? this.dangerInk,
      dangerBg: dangerBg ?? this.dangerBg,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      food: food ?? this.food,
      transport: transport ?? this.transport,
      data: data ?? this.data,
      bills: bills ?? this.bills,
      fun: fun ?? this.fun,
      other: other ?? this.other,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      card: c(card, other.card),
      bodyText: c(bodyText, other.bodyText),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      divider: c(divider, other.divider),
      track: c(track, other.track),
      segmentBg: c(segmentBg, other.segmentBg),
      chartMuted: c(chartMuted, other.chartMuted),
      chartFaint: c(chartFaint, other.chartFaint),
      primaryTrack: c(primaryTrack, other.primaryTrack),
      warning: c(warning, other.warning),
      warningTrack: c(warningTrack, other.warningTrack),
      warningText: c(warningText, other.warningText),
      warningBg: c(warningBg, other.warningBg),
      warningBorder: c(warningBorder, other.warningBorder),
      warningInk: c(warningInk, other.warningInk),
      danger: c(danger, other.danger),
      dangerTrack: c(dangerTrack, other.dangerTrack),
      dangerText: c(dangerText, other.dangerText),
      dangerInk: c(dangerInk, other.dangerInk),
      dangerBg: c(dangerBg, other.dangerBg),
      dangerBorder: c(dangerBorder, other.dangerBorder),
      food: CategoryColors.lerp(food, other.food, t),
      transport: CategoryColors.lerp(transport, other.transport, t),
      data: CategoryColors.lerp(data, other.data, t),
      bills: CategoryColors.lerp(bills, other.bills, t),
      fun: CategoryColors.lerp(fun, other.fun, t),
      other: CategoryColors.lerp(this.other, other.other, t),
    );
  }
}

/// Light and dark [ThemeData] for MaterialApp.
abstract final class AppTheme {
  static final ThemeData light = _build(
    ColorScheme.fromSeed(seedColor: AppTokens.primary).copyWith(
      primary: AppTokens.primary,
      onPrimary: AppTokens.white,
      primaryContainer: AppTokens.container,
      onPrimaryContainer: AppTokens.primaryText,
      surface: AppTokens.surface,
      onSurface: AppTokens.ink,
      onSurfaceVariant: AppTokens.muted,
      surfaceContainerLowest: AppTokens.white,
      surfaceContainerHighest: AppTokens.segmentBg,
      outline: AppTokens.borderStrong,
      outlineVariant: AppTokens.border,
      error: AppTokens.danger,
      onError: AppTokens.white,
      errorContainer: AppTokens.dangerBg,
      onErrorContainer: AppTokens.dangerInk,
    ),
    AppPalette.light,
    BudgetStatusColors.light,
  );

  static final ThemeData dark = () {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppTokens.primary,
      brightness: Brightness.dark,
    );
    final palette = AppPalette.dark(scheme);
    return _build(scheme, palette, BudgetStatusColors.dark(palette, scheme));
  }();

  static ThemeData _build(
    ColorScheme scheme,
    AppPalette palette,
    BudgetStatusColors budget,
  ) {
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );
    const buttonSize = Size.fromHeight(56);
    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: AppTextStyles.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      dividerTheme: DividerThemeData(color: palette.divider, space: 1),
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: palette.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          foregroundColor: scheme.onSurface,
          backgroundColor: palette.card,
          side: BorderSide(color: palette.borderStrong),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.brightness == Brightness.light
              ? AppTokens.primaryText
              : scheme.primary,
          textStyle: AppTextStyles.bodyStrong,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: inputBorder(palette.borderStrong),
        enabledBorder: inputBorder(palette.borderStrong),
        focusedBorder: inputBorder(scheme.primary, 2),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, 2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 76,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppTextStyles.smallStrong.copyWith(
                  color: scheme.onPrimaryContainer,
                )
              : AppTextStyles.smallMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      extensions: [palette, budget],
    );
  }
}

/// Spacing scale, measured from the screen exports.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  /// Left and right padding of every screen.
  static const screen = 20.0;
}

/// Corner radii, measured from the screen exports.
abstract final class AppRadius {
  static const input = 12.0;
  static const tile = 14.0;
  static const button = 16.0;
  static const card = 20.0;
}
