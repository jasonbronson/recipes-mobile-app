part of 'package:iosapp/main.dart';

const Color _darkPrimary = Color(0xFFFFB050);
const Color _darkOnPrimary = Color(0xFF381E00);
const Color _darkPrimaryContainer = Color(0xFF4F2F12);
const Color _darkOnPrimaryContainer = Color(0xFFFFDCC2);
const Color _darkSecondary = Color(0xFFFFB050);
const Color _darkOnSecondary = Color(0xFF381E00);
const Color _darkSecondaryContainer = Color(0xFF5A371A);
const Color _darkOnSecondaryContainer = Color(0xFFFFDCC2);
const Color _darkTertiary = Color(0xFF6BD3A6);
const Color _darkOnTertiary = Color(0xFF003822);
const Color _darkTertiaryContainer = Color(0xFF005235);
const Color _darkOnTertiaryContainer = Color(0xFF88FBC4);
const Color _darkError = Color(0xFFFFB4AB);
const Color _darkOnError = Color(0xFF690005);
const Color _darkErrorContainer = Color(0xFF93000A);
const Color _darkOnErrorContainer = Color(0xFFFFDAD6);
const Color _darkBackground = Color(0xFF1F1A17);
const Color _darkOnBackground = Color(0xFFEDE5DF);
const Color _darkSurface = Color(0xFF26201C);
const Color _darkOnSurface = Color(0xFFEDE5DF);
const Color _darkSurfaceVariant = Color(0xFF3B3028);
const Color _darkOnSurfaceVariant = Color(0xFFCBBCAF);
const Color _darkOutline = Color(0xFF8F7D73);
const Color _darkOutlineVariant = Color(0xFF4E4139);
const Color _darkShadow = Color(0xFF000000);
const Color _darkScrim = Color(0xFF000000);
const Color _darkInverseSurface = Color(0xFFEDE5DF);
const Color _darkOnInverseSurface = Color(0xFF2E231C);
const Color _darkInversePrimary = Color(0xFF8C5F28);
const Color _darkSurfaceTint = _darkPrimary;

const Color _lightPrimary = Color(0xFF1FB874);
const Color _lightOnPrimary = Color(0xFFFFFFFF);
const Color _lightPrimaryContainer = Color(0xFFD5F6E7);
const Color _lightOnPrimaryContainer = Color(0xFF002111);
const Color _lightSecondary = Color(0xFF1FB874);
const Color _lightOnSecondary = Color(0xFFFFFFFF);
const Color _lightSecondaryContainer = Color(0xFFE2F8EF);
const Color _lightOnSecondaryContainer = Color(0xFF003920);
const Color _lightTertiary = Color(0xFF44576A);
const Color _lightOnTertiary = Color(0xFFFFFFFF);
const Color _lightTertiaryContainer = Color(0xFFDCE5F2);
const Color _lightOnTertiaryContainer = Color(0xFF021C2C);
const Color _lightError = Color(0xFFBA1A1A);
const Color _lightOnError = Color(0xFFFFFFFF);
const Color _lightErrorContainer = Color(0xFFFFDAD6);
const Color _lightOnErrorContainer = Color(0xFF410002);
const Color _lightBackground = Color(0xFFF6F7FB);
const Color _lightOnBackground = Color(0xFF1C2330);
const Color _lightSurface = Color(0xFFFFFFFF);
const Color _lightOnSurface = Color(0xFF1C2330);
const Color _lightSurfaceVariant = Color(0xFFE1E5EB);
const Color _lightOnSurfaceVariant = Color(0xFF5C6672);
const Color _lightOutline = Color(0xFFD0D6DD);
const Color _lightOutlineVariant = Color(0xFFB5BDC6);
const Color _lightShadow = Color(0xFF000000);
const Color _lightScrim = Color(0xFF000000);
const Color _lightInverseSurface = Color(0xFF2E3745);
const Color _lightOnInverseSurface = Color(0xFFF0F4F8);
const Color _lightInversePrimary = Color(0xFF0D8A54);
const Color _lightSurfaceTint = _lightPrimary;

const ColorScheme _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: _darkPrimary,
  onPrimary: _darkOnPrimary,
  primaryContainer: _darkPrimaryContainer,
  onPrimaryContainer: _darkOnPrimaryContainer,
  secondary: _darkSecondary,
  onSecondary: _darkOnSecondary,
  secondaryContainer: _darkSecondaryContainer,
  onSecondaryContainer: _darkOnSecondaryContainer,
  tertiary: _darkTertiary,
  onTertiary: _darkOnTertiary,
  tertiaryContainer: _darkTertiaryContainer,
  onTertiaryContainer: _darkOnTertiaryContainer,
  error: _darkError,
  onError: _darkOnError,
  errorContainer: _darkErrorContainer,
  onErrorContainer: _darkOnErrorContainer,
  surface: _darkSurface,
  onSurface: _darkOnSurface,
  surfaceContainerHigh: _darkSurfaceVariant,
  surfaceContainerHighest: _darkSurfaceVariant,
  onSurfaceVariant: _darkOnSurfaceVariant,
  outline: _darkOutline,
  outlineVariant: _darkOutlineVariant,
  shadow: _darkShadow,
  scrim: _darkScrim,
  inverseSurface: _darkInverseSurface,
  onInverseSurface: _darkOnInverseSurface,
  inversePrimary: _darkInversePrimary,
  surfaceTint: _darkSurfaceTint,
);

const ColorScheme _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: _lightPrimary,
  onPrimary: _lightOnPrimary,
  primaryContainer: _lightPrimaryContainer,
  onPrimaryContainer: _lightOnPrimaryContainer,
  secondary: _lightSecondary,
  onSecondary: _lightOnSecondary,
  secondaryContainer: _lightSecondaryContainer,
  onSecondaryContainer: _lightOnSecondaryContainer,
  tertiary: _lightTertiary,
  onTertiary: _lightOnTertiary,
  tertiaryContainer: _lightTertiaryContainer,
  onTertiaryContainer: _lightOnTertiaryContainer,
  error: _lightError,
  onError: _lightOnError,
  errorContainer: _lightErrorContainer,
  onErrorContainer: _lightOnErrorContainer,
  surface: _lightSurface,
  onSurface: _lightOnSurface,
  surfaceContainerHigh: _lightSurfaceVariant,
  surfaceContainerHighest: _lightSurfaceVariant,
  onSurfaceVariant: _lightOnSurfaceVariant,
  outline: _lightOutline,
  outlineVariant: _lightOutlineVariant,
  shadow: _lightShadow,
  scrim: _lightScrim,
  inverseSurface: _lightInverseSurface,
  onInverseSurface: _lightOnInverseSurface,
  inversePrimary: _lightInversePrimary,
  surfaceTint: _lightSurfaceTint,
);

ThemeMode _themeModeFromStored(String? stored) {
  switch (stored) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
    default:
      return ThemeMode.dark;
  }
}

String _themeModeToStored(ThemeMode mode) {
  return mode == ThemeMode.light ? 'light' : 'dark';
}

ThemeData _buildAppTheme(
  ColorScheme scheme, {
  required Color background,
  required Color onBackground,
}) {
  final bool isDark = scheme.brightness == Brightness.dark;
  final ThemeData base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: scheme.brightness,
  );

  final TextTheme baseTextTheme = base.textTheme.apply(
    bodyColor: scheme.onSurface,
    displayColor: onBackground,
  );

  final Color elevatedSurface = scheme.surfaceContainerHigh;
  final Color highestSurface = scheme.surfaceContainerHighest;

  final TextStyle defaultLabel =
      baseTextTheme.labelLarge ?? const TextStyle(fontSize: 14);

  return base.copyWith(
    scaffoldBackgroundColor: background,
    textTheme: baseTextTheme.copyWith(
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.45),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
        height: 1.4,
      ),
      labelLarge: defaultLabel.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: onBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 24,
      toolbarHeight: 84,
      titleTextStyle: baseTextTheme.headlineSmall?.copyWith(
        color: onBackground,
        fontWeight: FontWeight.w700,
        fontSize: 32,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 24),
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      elevation: 0,
      height: 80,
      indicatorColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
        Set<WidgetState> states,
      ) {
        final bool selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? scheme.secondary : scheme.onSurfaceVariant,
          size: selected ? 28 : 26,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
        Set<WidgetState> states,
      ) {
        final bool selected = states.contains(WidgetState.selected);
        return defaultLabel.copyWith(
          color: selected ? scheme.secondary : scheme.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: defaultLabel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: defaultLabel,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: defaultLabel.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? elevatedSurface : scheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.secondary, width: 2),
      ),
      labelStyle: baseTextTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      hintStyle: baseTextTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: highestSurface,
      contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      actionTextColor: scheme.secondary,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      iconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      tileColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.secondary),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
  );
}

final ThemeData _darkTheme = _buildAppTheme(
  _darkColorScheme,
  background: _darkBackground,
  onBackground: _darkOnBackground,
);
final ThemeData _lightTheme = _buildAppTheme(
  _lightColorScheme,
  background: _lightBackground,
  onBackground: _lightOnBackground,
);
