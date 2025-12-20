import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const String _localBaseUrl = 'http://192.168.2.143:8080';
const String _productionBaseUrl = 'https://apicooking.bronson.dev';
const String _localTestingEmail = 'jasonbronson@gmail.com';
const String _tokenStorageKey = 'authToken';
const String _emailStorageKey = 'userEmail';
const String _biometricEnabledStorageKey = 'biometricEnabled';
const String _biometricTokenStorageKey = 'biometricToken';
const String _biometricEmailStorageKey = 'biometricEmail';
const String _themePreferenceKey = 'preferredThemeMode';

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

enum _PendingRecipeStatus { queued, saving, awaitingImport }

class _PendingRecipeEntry {
  const _PendingRecipeEntry({
    required this.id,
    required this.url,
    this.status = _PendingRecipeStatus.queued,
  });

  final String id;
  final String url;
  final _PendingRecipeStatus status;

  _PendingRecipeEntry copyWith({
    String? id,
    String? url,
    _PendingRecipeStatus? status,
  }) {
    return _PendingRecipeEntry(
      id: id ?? this.id,
      url: url ?? this.url,
      status: status ?? this.status,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final ThemeMode initialThemeMode = _themeModeFromStored(
    prefs.getString(_themePreferenceKey),
  );
  runApp(ShareHandlerApp(initialThemeMode: initialThemeMode));
}

class ShareHandlerApp extends StatefulWidget {
  const ShareHandlerApp({super.key, required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  @override
  State<ShareHandlerApp> createState() => _ShareHandlerAppState();
}

class _ShareHandlerAppState extends State<ShareHandlerApp> {
  late ThemeMode _themeMode = widget.initialThemeMode;

  Future<void> _handleThemeModeChanged(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }
    setState(() {
      _themeMode = mode;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, _themeModeToStored(mode));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipes',
      themeMode: _themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: ShareDisplayPage(
        themeMode: _themeMode,
        onThemeModeChanged: _handleThemeModeChanged,
      ),
    );
  }
}

class ShareDisplayPage extends StatefulWidget {
  const ShareDisplayPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ShareDisplayPage> createState() => _ShareDisplayPageState();
}

class _ShareDisplayPageState extends State<ShareDisplayPage> {
  static const MethodChannel _platform = MethodChannel(
    'com.bronson.dev.iosapp/shared_data',
  );
  static const String _genericErrorMessage =
      'An error occurred. Please try again later.';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isCheckingAuth = true;
  bool _isAuthenticating = false;
  bool _isFetchingRecipes = false;
  int _selectedTabIndex = 0;

  String? _authToken;
  String? _authError;
  String? _currentUserEmail;
  List<Recipe> _recipes = <Recipe>[];
  List<_PendingRecipeEntry> _pendingSharedRecipes = <_PendingRecipeEntry>[];
  bool _isProcessingSharedQueue = false;
  Timer? _pendingImportRefreshTimer;
  int _pendingEntrySequence = 0;
  bool _biometricSupported = false;
  bool _biometricEnabled = false;
  bool _isBiometricAuthenticating = false;
  bool _hasAttemptedAutoBiometricLogin = false;
  late ThemeMode _currentThemeMode;

  String _baseUrl({String? emailOverride}) {
    final String? email = (emailOverride ?? _currentUserEmail)
        ?.trim()
        .toLowerCase();
    if (email == _localTestingEmail) {
      return _localBaseUrl;
    }
    return _productionBaseUrl;
  }

  @override
  void initState() {
    super.initState();
    _currentThemeMode = widget.themeMode;
    _setupMethodChannel();
    _initializeAuth();
    _initializeBiometrics();
  }

  @override
  void didUpdateWidget(covariant ShareDisplayPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeMode != widget.themeMode) {
      _currentThemeMode = widget.themeMode;
    }
  }

  bool get _isDarkTheme => _currentThemeMode != ThemeMode.light;

  void _updateThemePreference(ThemeMode mode) {
    if (_currentThemeMode == mode) {
      return;
    }
    setState(() {
      _currentThemeMode = mode;
    });
    widget.onThemeModeChanged(mode);
  }

  @override
  void dispose() {
    _pendingImportRefreshTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setupMethodChannel() {
    _platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'sharedData') {
        final String? sharedData = call.arguments as String?;
        if (sharedData != null && sharedData.isNotEmpty) {
          await _handleSharedData(sharedData);
        }
      }
    });
  }

  Future<void> _initializeBiometrics() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool enabled = prefs.getBool(_biometricEnabledStorageKey) ?? false;

      bool supported = false;
      bool hasBiometrics = false;
      try {
        supported = await _localAuth.isDeviceSupported();
        if (supported) {
          final List<BiometricType> available = await _localAuth
              .getAvailableBiometrics();
          hasBiometrics =
              available.contains(BiometricType.face) ||
              available.contains(BiometricType.strong);
        }
      } on PlatformException {
        supported = false;
        hasBiometrics = false;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _biometricSupported = supported && hasBiometrics;
        _biometricEnabled = enabled && _biometricSupported;
      });

      if (enabled && !_biometricSupported) {
        await _disableBiometricLogin(updatePreferences: true);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _biometricSupported = false;
        _biometricEnabled = false;
      });
    }

    if (!mounted) {
      return;
    }
    _maybeAttemptAutoBiometricLogin();
  }

  void _maybeAttemptAutoBiometricLogin() {
    if (!mounted ||
        _hasAttemptedAutoBiometricLogin ||
        _isCheckingAuth ||
        _authToken != null ||
        !_biometricSupported ||
        !_biometricEnabled ||
        _isAuthenticating ||
        _isBiometricAuthenticating) {
      return;
    }

    setState(() {
      _hasAttemptedAutoBiometricLogin = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loginWithBiometrics();
    });
  }

  Future<void> _initializeAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedToken = await _readPersistedToken(prefs);
    final String? storedEmail = prefs.getString(_emailStorageKey);

    if (!mounted) {
      return;
    }

    setState(() {
      _authToken = storedToken;
      _currentUserEmail = storedEmail;
      _isCheckingAuth = false;
      _selectedTabIndex = 0;
    });

    _maybeAttemptAutoBiometricLogin();

    if (storedEmail != null && storedEmail.isNotEmpty) {
      _emailController.text = storedEmail;
    }

    if (storedToken != null && storedToken.isNotEmpty) {
      await Future.wait(<Future<void>>[_fetchRecipes(), _fetchProfile()]);
      await _processSharedQueue();
    }
  }

  Future<bool> _enableBiometricLogin(String token, String email) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledStorageKey, true);
      await _secureStorage.write(key: _biometricTokenStorageKey, value: token);
      await _secureStorage.write(key: _biometricEmailStorageKey, value: email);

      if (!mounted) {
        return true;
      }

      setState(() {
        _biometricEnabled = true;
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _disableBiometricLogin({bool updatePreferences = false}) async {
    try {
      if (updatePreferences) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_biometricEnabledStorageKey, false);
      }
      await _secureStorage.delete(key: _biometricTokenStorageKey);
      await _secureStorage.delete(key: _biometricEmailStorageKey);
    } catch (_) {
      // Ignore secure storage errors when cleaning up.
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _biometricEnabled = false;
    });
  }

  Future<void> _maybePromptForBiometric(String token, String email) async {
    if (!_biometricSupported || _biometricEnabled || !mounted) {
      return;
    }

    final bool? shouldEnable = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Face ID?'),
          content: const Text(
            'Use Face ID to sign in quickly next time without entering your password.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );

    if (shouldEnable == true && mounted) {
      final bool enabled = await _enableBiometricLogin(token, email);
      if (enabled) {
        _showSnackBar('Face ID enabled for quick sign-in.');
      } else {
        _showSnackBar(
          'Unable to enable Face ID on this device.',
          isError: true,
        );
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    if (_isBiometricAuthenticating) {
      return;
    }

    setState(() {
      _isBiometricAuthenticating = true;
      _authError = null;
    });

    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Sign in with Face ID to access your recipes.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
          useErrorDialogs: true,
        ),
      );

      if (!authenticated) {
        return;
      }

      final String? token = await _secureStorage.read(
        key: _biometricTokenStorageKey,
      );
      final String? email = await _secureStorage.read(
        key: _biometricEmailStorageKey,
      );

      if (token == null || token.isEmpty || email == null || email.isEmpty) {
        await _disableBiometricLogin(updatePreferences: true);
        _showSnackBar(
          'Face ID sign-in is no longer available. Please sign in with your password.',
          isError: true,
        );
        return;
      }

      await _handleAuthenticationSuccess(token, email);
    } on PlatformException catch (error) {
      if (error.code == auth_error.notEnrolled) {
        _showSnackBar(
          'Face ID has not been set up on this device.',
          isError: true,
        );
      } else if (error.code == auth_error.lockedOut ||
          error.code == auth_error.permanentlyLockedOut) {
        _showSnackBar(
          'Face ID is locked. Please unlock it in Settings and try again.',
          isError: true,
        );
      } else {
        _showSnackBar(
          'Face ID could not be used right now. Please try again.',
          isError: true,
        );
      }
    } catch (_) {
      _showSnackBar(
        'Face ID could not be used right now. Please try again later.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBiometricAuthenticating = false;
        });
      }
    }
  }

  Future<void> _promptDisableBiometrics() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disable Face ID?'),
          content: const Text(
            'This device will forget the stored token and require your password next time.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Disable'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _disableBiometricLogin(updatePreferences: true);
      _showSnackBar('Face ID sign-in disabled for this device.');
    }
  }

  Future<void> _handleSharedData(String url) async {
    if (_authToken == null) {
      _showSnackBar('You must be logged in first to save shared recipes.');
      return;
    }

    _addPendingSharedRecipe(url);
    await _processSharedQueue();
  }

  Future<bool> _sendSharedUrl(
    String url, {
    bool refreshAfterSave = true,
    bool showSuccessSnackBar = true,
  }) async {
    final String? token = _authToken;
    if (token == null) {
      return false;
    }

    try {
      final http.Response response = await http.post(
        Uri.parse('${_baseUrl()}/save-recipe'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{'url': url}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted && showSuccessSnackBar) {
          _showSnackBar('Recipe saved from shared URL.');
        }

        if (refreshAfterSave && mounted) {
          await _fetchRecipes();
        }
        return true;
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
      } else {
        final String reason =
            _extractError(response.body) ?? _genericErrorMessage;
        _showSnackBar('Failed to save recipe. $reason', isError: true);
      }
    } catch (_) {
      _showSnackBar(
        'Failed to save recipe. $_genericErrorMessage',
        isError: true,
      );
    }

    return false;
  }

  Future<void> _processSharedQueue() async {
    if (_isProcessingSharedQueue || _authToken == null) {
      return;
    }

    final bool hasQueued = _pendingSharedRecipes.any(
      (_PendingRecipeEntry entry) =>
          entry.status == _PendingRecipeStatus.queued,
    );
    if (!hasQueued) {
      _schedulePendingImportRefresh();
      return;
    }

    _isProcessingSharedQueue = true;
    int processedCount = 0;

    try {
      while (_authToken != null) {
        final int index = _pendingSharedRecipes.indexWhere(
          (_PendingRecipeEntry entry) =>
              entry.status == _PendingRecipeStatus.queued,
        );
        if (index == -1) {
          break;
        }

        final _PendingRecipeEntry current = _pendingSharedRecipes[index];
        _updatePendingEntryById(
          current.id,
          (_PendingRecipeEntry entry) =>
              entry.copyWith(status: _PendingRecipeStatus.saving),
        );

        final bool saved = await _sendSharedUrl(
          current.url,
          refreshAfterSave: false,
          showSuccessSnackBar: false,
        );

        if (!mounted) {
          return;
        }

        if (saved) {
          processedCount += 1;
          _updatePendingEntryById(
            current.id,
            (_PendingRecipeEntry entry) =>
                entry.copyWith(status: _PendingRecipeStatus.awaitingImport),
          );

          await _fetchRecipes();
          if (!mounted) {
            return;
          }
          _pruneImportedPendingEntries();
        } else {
          _updatePendingEntryById(
            current.id,
            (_PendingRecipeEntry entry) =>
                entry.copyWith(status: _PendingRecipeStatus.queued),
          );
          break;
        }
      }
    } finally {
      _isProcessingSharedQueue = false;
    }

    if (!mounted) {
      return;
    }

    if (processedCount > 0) {
      _showSnackBar(
        processedCount == 1
            ? 'Recipe download started. We\'ll add it once ready.'
            : 'Recipe downloads started. We\'ll add them once ready.',
      );
    }

    _schedulePendingImportRefresh();
  }

  void _addPendingSharedRecipe(String url) {
    if (!mounted) {
      return;
    }
    final String id =
        'pending-${_pendingEntrySequence++}-${DateTime.now().microsecondsSinceEpoch}';
    final _PendingRecipeEntry entry = _PendingRecipeEntry(id: id, url: url);
    final List<_PendingRecipeEntry> updated = List<_PendingRecipeEntry>.from(
      _pendingSharedRecipes,
    )..add(entry);
    _replacePendingEntries(updated);
  }

  void _replacePendingEntries(List<_PendingRecipeEntry> entries) {
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingSharedRecipes = entries;
    });
    _schedulePendingImportRefresh();
  }

  void _updatePendingEntryById(
    String id,
    _PendingRecipeEntry Function(_PendingRecipeEntry entry) transform,
  ) {
    if (!mounted) {
      return;
    }
    final int index = _pendingSharedRecipes.indexWhere(
      (_PendingRecipeEntry entry) => entry.id == id,
    );
    if (index == -1) {
      return;
    }
    final List<_PendingRecipeEntry> updated = List<_PendingRecipeEntry>.from(
      _pendingSharedRecipes,
    );
    updated[index] = transform(updated[index]);
    _replacePendingEntries(updated);
  }

  void _removePendingEntryById(String id) {
    if (!mounted) {
      return;
    }
    final List<_PendingRecipeEntry> updated = _pendingSharedRecipes
        .where((_PendingRecipeEntry entry) => entry.id != id)
        .toList(growable: false);
    if (updated.length == _pendingSharedRecipes.length) {
      return;
    }
    _replacePendingEntries(updated);
  }

  void _schedulePendingImportRefresh() {
    _pendingImportRefreshTimer?.cancel();
    if (!_pendingSharedRecipes.any(
      (_PendingRecipeEntry entry) =>
          entry.status == _PendingRecipeStatus.awaitingImport,
    )) {
      _pendingImportRefreshTimer = null;
      return;
    }

    _pendingImportRefreshTimer = Timer(const Duration(seconds: 5), () async {
      _pendingImportRefreshTimer = null;
      if (!mounted) {
        return;
      }
      if (!_pendingSharedRecipes.any(
        (_PendingRecipeEntry entry) =>
            entry.status == _PendingRecipeStatus.awaitingImport,
      )) {
        return;
      }
      await _fetchRecipes();
      if (!mounted) {
        return;
      }
      _pruneImportedPendingEntries();
    });
  }

  void _pruneImportedPendingEntries() {
    if (_pendingSharedRecipes.isEmpty) {
      _pendingImportRefreshTimer?.cancel();
      _pendingImportRefreshTimer = null;
      return;
    }

    final List<_PendingRecipeEntry> retained = <_PendingRecipeEntry>[];
    for (final _PendingRecipeEntry entry in _pendingSharedRecipes) {
      if (entry.status == _PendingRecipeStatus.awaitingImport &&
          _recipesContainUrl(entry.url)) {
        continue;
      }
      retained.add(entry);
    }

    final int removedCount = _pendingSharedRecipes.length - retained.length;

    if (removedCount > 0) {
      _replacePendingEntries(retained);
      _showSnackBar(
        removedCount == 1
            ? 'Recipe saved from shared URL.'
            : 'Saved $removedCount shared recipes.',
      );
    } else {
      _schedulePendingImportRefresh();
    }
  }

  bool _recipesContainUrl(String url) {
    final Uri? target = _tryParseHttpUri(url);
    if (target == null) {
      return false;
    }
    final String normalizedTarget = _normalizedUriKey(target);
    for (final Recipe recipe in _recipes) {
      for (final Uri candidate in recipe.originalUris) {
        if (_normalizedUriKey(candidate) == normalizedTarget) {
          return true;
        }
      }
    }
    return false;
  }

  Uri? _tryParseHttpUri(String value) {
    if (value.isEmpty) {
      return null;
    }
    try {
      final Uri uri = Uri.parse(value);
      if (!uri.hasScheme ||
          (uri.scheme != 'http' && uri.scheme != 'https') ||
          uri.host.isEmpty) {
        return null;
      }
      return uri;
    } catch (_) {
      return null;
    }
  }

  String _normalizedUriKey(Uri uri) {
    final String host = uri.host.toLowerCase().replaceFirst(
      RegExp('^www\\.'),
      '',
    );
    String path = uri.path.isEmpty ? '/' : uri.path;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    final String query = uri.hasQuery ? '?${uri.query}' : '';
    return '$host$path$query';
  }

  Future<void> _handleUnauthorized() async {
    // Server indicates the token is invalid; clear persisted auth.
    await _clearToken(preserveBiometric: false);
    _showSnackBar('Session expired. Please login again.', isError: true);
  }

  Future<void> _clearToken({bool preserveBiometric = true}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _removePersistedToken(prefs);
    await prefs.remove(_emailStorageKey);

    if (!preserveBiometric) {
      await _disableBiometricLogin(updatePreferences: true);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _authToken = null;
      _currentUserEmail = null;
      _recipes = <Recipe>[];
      _selectedTabIndex = 0;
      _pendingSharedRecipes = <_PendingRecipeEntry>[];
      _pendingEntrySequence = 0;
      _hasAttemptedAutoBiometricLogin = false;
    });
    _pendingImportRefreshTimer?.cancel();
    _pendingImportRefreshTimer = null;

    _maybeAttemptAutoBiometricLogin();
  }

  Future<String?> _readPersistedToken(SharedPreferences prefs) async {
    String? token;
    try {
      token = await _secureStorage.read(key: _tokenStorageKey);
    } catch (_) {
      token = null;
    }
    if (token != null && token.isNotEmpty) {
      return token;
    }

    final String? legacyToken = prefs.getString(_tokenStorageKey);
    if (legacyToken != null && legacyToken.isNotEmpty) {
      try {
        await _secureStorage.write(key: _tokenStorageKey, value: legacyToken);
      } catch (_) {
        // Ignore secure storage errors and fall back to legacy storage.
      }
      return legacyToken;
    }
    return null;
  }

  Future<void> _persistAuthToken(String token, SharedPreferences prefs) async {
    try {
      await _secureStorage.write(key: _tokenStorageKey, value: token);
    } catch (_) {
      // Ignore secure storage errors and still persist to user defaults.
    }
    await prefs.setString(_tokenStorageKey, token);
  }

  Future<void> _removePersistedToken(SharedPreferences prefs) async {
    try {
      await _secureStorage.delete(key: _tokenStorageKey);
    } catch (_) {
      // Ignore secure storage errors during cleanup.
    }
    await prefs.remove(_tokenStorageKey);
  }

  Future<void> _login() async {
    if (_isBiometricAuthenticating) {
      return;
    }
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _authError = 'Email and password are required.';
      });
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _authError = null;
    });

    await _authenticate(email, password);
  }

  Future<void> _register() async {
    if (_isBiometricAuthenticating) {
      return;
    }
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _authError = 'Email and password are required.';
      });
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _authError = null;
    });

    try {
      final http.Response response = await http.post(
        Uri.parse('${_baseUrl(emailOverride: email)}/register'),
        headers: const <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _authenticate(email, password);
        return;
      }

      final String reason =
          _extractError(response.body) ?? _genericErrorMessage;
      setState(() {
        _authError = response.statusCode == 409
            ? 'An account already exists for that email.'
            : 'Registration failed: $reason';
      });
    } catch (_) {
      setState(() {
        _authError = 'Registration failed. $_genericErrorMessage';
      });
    } finally {
      if (mounted && _authToken == null) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _handleAuthenticationSuccess(String token, String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _persistAuthToken(token, prefs);
    await prefs.setString(_emailStorageKey, email);

    if (!mounted) {
      return;
    }

    setState(() {
      _authToken = token;
      _currentUserEmail = email;
      _authError = null;
      _selectedTabIndex = 0;
    });

    try {
      await Future.wait(<Future<void>>[_fetchRecipes(), _fetchProfile()]);
    } catch (_) {
      // Fail silently; individual calls already surface errors.
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }

    await _processSharedQueue();
  }

  Future<bool> _authenticate(String email, String password) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('${_baseUrl(emailOverride: email)}/login'),
        headers: const <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final String? token = _parseTokenFromResponse(response.body);
        if (token == null || token.isEmpty) {
          if (mounted) {
            setState(() {
              _authError = 'Login response did not include an access token.';
              _isAuthenticating = false;
            });
          }
          return false;
        }

        await _handleAuthenticationSuccess(token, email);
        await _maybePromptForBiometric(token, email);
        return true;
      }

      final String reason =
          _extractError(response.body) ?? _genericErrorMessage;
      if (mounted) {
        setState(() {
          _authError = 'Login failed: $reason';
          _isAuthenticating = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _authError = 'Login failed. $_genericErrorMessage';
          _isAuthenticating = false;
        });
      }
    }

    return false;
  }

  Future<void> _fetchRecipes({bool ignoreCache = false}) async {
    final String? token = _authToken;
    if (token == null) {
      return;
    }

    setState(() {
      _isFetchingRecipes = true;
    });

    try {
      final String refreshSuffix = ignoreCache ? '?refresh=true' : '';
      final http.Response response = await http.get(
        Uri.parse('${_baseUrl()}/get-recipes$refreshSuffix'),
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<Recipe> recipes = Recipe.listFromAny(
          response.body.isEmpty ? <dynamic>[] : jsonDecode(response.body),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _recipes = recipes;
        });
        _pruneImportedPendingEntries();
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
      } else {
        final String reason =
            _extractError(response.body) ?? _genericErrorMessage;
        _showSnackBar('Failed to load recipes. $reason', isError: true);
      }
    } catch (_) {
      _showSnackBar(
        'Failed to load recipes. $_genericErrorMessage',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingRecipes = false;
        });
      }
    }
  }

  Future<void> _fetchProfile() async {
    final String? token = _authToken;
    if (token == null) {
      return;
    }

    try {
      final http.Response response = await http.get(
        Uri.parse('${_baseUrl()}/profile'),
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = response.body.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(response.body);
        final String? email = (decoded is Map<String, dynamic>)
            ? Recipe._stringOrNull(decoded['email'])
            : null;
        if (email != null && email.isNotEmpty) {
          if (!mounted) {
            return;
          }
          setState(() {
            _currentUserEmail = email;
          });
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(_emailStorageKey, email);
        }
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
      } else {
        // Silently ignore other errors but keep stored email.
      }
    } catch (_) {
      // Ignore network/profile errors to avoid noisy UI.
    }
  }

  Future<bool> _deleteRecipe(Recipe recipe) async {
    final String id = recipe.id.trim();
    if (id.isEmpty) {
      _showSnackBar('Unable to remove this recipe.', isError: true);
      return false;
    }

    final String? token = _authToken;
    if (token == null) {
      _showSnackBar('You must be logged in to remove recipes.', isError: true);
      return false;
    }

    try {
      final http.Response response = await http.delete(
        Uri.parse('${_baseUrl()}/recipes/id/$id'),
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _removeRecipeById(id);
        _showSnackBar('Removed ${recipe.title}');
        return true;
      }

      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return false;
      }

      final String reason =
          _extractError(response.body) ?? _genericErrorMessage;
      _showSnackBar(reason, isError: true);
    } catch (_) {
      _showSnackBar(_genericErrorMessage, isError: true);
    }

    return false;
  }

  void _removeRecipeById(String id) {
    if (!mounted) {
      return;
    }
    setState(() {
      _recipes = _recipes
          .where((Recipe recipe) => recipe.id != id)
          .toList(growable: false);
    });
  }

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearToken();
              },
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openRecipeDetail(Recipe recipe) async {
    final String? token = _authToken;
    if (token == null) {
      _showSnackBar('You must be logged in to view recipes.', isError: true);
      return;
    }

    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => RecipeDetailPage(
          recipe: recipe,
          authToken: token,
          onFavoriteToggle: (String recipeId, bool value) =>
              _setFavoriteStatus(recipeId, value),
          baseUrl: _baseUrl(),
        ),
      ),
    );

    await _fetchRecipes();
  }

  String? _extractError(String body) {
    if (body.isEmpty) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        for (final String key in <String>[
          'message',
          'error',
          'detail',
          'description',
        ]) {
          final dynamic value = decoded[key];
          if (value is String && value.isNotEmpty) {
            return _friendlyError(value);
          }
        }
      }
    } catch (_) {
      // Ignore JSON parsing errors and fall back to raw body if short enough.
    }

    return _friendlyError(body);
  }

  String _friendlyError(String? message) {
    final String trimmed = (message ?? '').trim();
    if (trimmed.isEmpty) {
      return _genericErrorMessage;
    }
    if (trimmed.length > 120 || trimmed.contains('\n')) {
      return _genericErrorMessage;
    }
    return trimmed;
  }

  String? _parseTokenFromResponse(String body) {
    final String trimmed = body.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(trimmed);
      return _searchToken(decoded);
    } catch (_) {
      if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
        try {
          return jsonDecode(trimmed) as String;
        } catch (_) {
          return null;
        }
      }

      if (trimmed.startsWith('Bearer ')) {
        return trimmed.substring(7).trim();
      }

      return trimmed.length > 10 ? trimmed : null;
    }
  }

  String? _searchToken(dynamic value) {
    if (value is Map<String, dynamic>) {
      for (final String key in <String>[
        'token',
        'access_token',
        'accessToken',
        'jwt',
      ]) {
        final dynamic potential = value[key];
        if (potential is String && potential.isNotEmpty) {
          return potential;
        }
      }

      for (final dynamic nested in value.values) {
        final String? found = _searchToken(nested);
        if (found != null && found.isNotEmpty) {
          return found;
        }
      }
    } else if (value is List<dynamic>) {
      for (final dynamic item in value) {
        final String? found = _searchToken(item);
        if (found != null && found.isNotEmpty) {
          return found;
        }
      }
    } else if (value is String && value.isNotEmpty && value.length > 10) {
      return value;
    }

    return null;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;

    if (_isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_authToken == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Recipes')),
        body: _buildLoginForm(theme),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForTab(_selectedTabIndex)),
        actions: _actionsForTab(),
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: <Widget>[
          _buildRecipesView(),
          _buildCategoriesView(),
          _buildFavoritesView(),
          _buildAccountView(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          boxShadow: isLightTheme
              ? <BoxShadow>[
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.04),
                    offset: const Offset(0, -2),
                    blurRadius: 18,
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: NavigationBar(
          selectedIndex: _selectedTabIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Recipes',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.star_border_rounded),
              selectedIcon: Icon(Icons.star_rounded),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_emotions_outlined),
              selectedIcon: Icon(Icons.emoji_emotions_rounded),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Welcome back',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to sync and save your recipes.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const <String>[AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                autofillHints: const <String>[AutofillHints.password],
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_authError != null) ...<Widget>[
                const SizedBox(height: 16),
                Text(
                  _authError!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isAuthenticating ? null : _login,
                icon: _isAuthenticating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_open),
                label: Text(_isAuthenticating ? 'Signing in…' : 'Sign in'),
              ),
              if (_biometricSupported && _biometricEnabled) ...<Widget>[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: (_isAuthenticating || _isBiometricAuthenticating)
                      ? null
                      : _loginWithBiometrics,
                  icon: _isBiometricAuthenticating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.face_rounded),
                  label: Text(
                    _isBiometricAuthenticating
                        ? 'Authenticating…'
                        : 'Sign in with Face ID',
                  ),
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: (_isAuthenticating || _isBiometricAuthenticating)
                    ? null
                    : _register,
                child: const Text('Create a new account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipesView() {
    if (_isFetchingRecipes && _recipes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final int pendingCount = _pendingSharedRecipes.length;
    final bool hasRecipes = _recipes.isNotEmpty;
    final bool hasPending = pendingCount > 0;
    final int itemCount = hasPending
        ? pendingCount + (hasRecipes ? _recipes.length : 0)
        : (hasRecipes ? _recipes.length : 1);

    return RefreshIndicator(
      color: scheme.secondary,
      backgroundColor: scheme.surface,
      onRefresh: () => _fetchRecipes(ignoreCache: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 160),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          if (hasPending && index < pendingCount) {
            final _PendingRecipeEntry entry = _pendingSharedRecipes[index];
            return _PendingRecipeListItem(
              url: entry.url,
              position: index,
              total: pendingCount,
              status: entry.status,
              onRemove: () {
                _removePendingEntryById(entry.id);
                if (_authToken != null) {
                  _processSharedQueue();
                }
              },
            );
          }

          if (!hasRecipes) {
            return Padding(
              padding: const EdgeInsets.only(top: 64.0),
              child: Center(
                child: Text(
                  'No recipes yet. Shared recipes will appear here once processed.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            );
          }

          final int recipeIndex = hasPending ? index - pendingCount : index;
          final Recipe recipe = _recipes[recipeIndex];
          return _buildDismissibleRecipe(
            recipe,
            child: _RecipeListItem(
              recipe: recipe,
              onTap: () => _openRecipeDetail(recipe),
              onToggleFavorite: recipe.id.trim().isEmpty
                  ? null
                  : () {
                      _toggleFavoriteForRecipe(recipe);
                    },
            ),
          );
        },
      ),
    );
  }

  String _titleForTab(int index) {
    switch (index) {
      case 0:
        return 'Recipes';
      case 1:
        return 'Categories';
      case 2:
        return 'Favorites';
      case 3:
        return 'Account';
      default:
        return 'Recipes';
    }
  }

  List<Widget>? _actionsForTab() {
    switch (_selectedTabIndex) {
      case 0:
        return <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isFetchingRecipes
                ? null
                : () {
                    _fetchRecipes(ignoreCache: true);
                  },
            tooltip: 'Refresh recipes',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
            tooltip: 'Search recipes',
          ),
        ];
      case 1:
        return <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isFetchingRecipes
                ? null
                : () {
                    _fetchRecipes(ignoreCache: true);
                  },
            tooltip: 'Refresh categories',
          ),
        ];
      case 2:
        return <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isFetchingRecipes
                ? null
                : () {
                    _fetchRecipes(ignoreCache: true);
                  },
            tooltip: 'Refresh favorites',
          ),
        ];
      default:
        return null;
    }
  }

  Future<void> _startSearch() async {
    final String? token = _authToken;
    if (token == null) {
      _showSnackBar('You must be logged in to search.', isError: true);
      return;
    }

    final Recipe? selected = await showSearch<Recipe?>(
      context: context,
      delegate: RecipeSearchDelegate(search: _performRecipeSearch),
    );

    if (selected != null) {
      await _openRecipeDetail(selected);
    }
  }

  Future<List<Recipe>> _performRecipeSearch(String query) async {
    final String? token = _authToken;
    if (token == null || query.trim().isEmpty) {
      return <Recipe>[];
    }

    final Uri uri = Uri.parse(
      '${_baseUrl()}/search-recipes?q=${Uri.encodeQueryComponent(query.trim())}',
    );

    try {
      final http.Response response = await http.get(
        uri,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = response.body.isEmpty
            ? <dynamic>[]
            : jsonDecode(response.body);
        return Recipe.listFromAny(decoded);
      }

      if (response.statusCode == 401) {
        await _handleUnauthorized();
        throw Exception('Session expired. Please login again.');
      }

      final String reason =
          _extractError(response.body) ?? _genericErrorMessage;
      throw Exception(reason);
    } catch (_) {
      throw Exception(_genericErrorMessage);
    }
  }

  Future<void> _toggleFavoriteForRecipe(Recipe recipe) async {
    final String id = recipe.id.trim();
    if (id.isEmpty) {
      _showSnackBar(
        'Unable to update favorites for this recipe.',
        isError: true,
      );
      return;
    }

    await _setFavoriteStatus(
      id,
      !recipe.isFavorite,
      showFeedback: true,
      recipeTitle: recipe.title,
    );
  }

  Future<bool> _setFavoriteStatus(
    String recipeId,
    bool isFavorite, {
    bool showFeedback = false,
    String? recipeTitle,
  }) async {
    final String? token = _authToken;
    if (token == null) {
      _showSnackBar(
        'You must be logged in to update favorites.',
        isError: true,
      );
      return false;
    }

    try {
      final Uri uri = Uri.parse('${_baseUrl()}/recipes/id/$recipeId/favorite');
      final http.Response response = isFavorite
          ? await http.post(
              uri,
              headers: <String, String>{
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            )
          : await http.delete(
              uri,
              headers: <String, String>{'Authorization': 'Bearer $token'},
            );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _updateRecipeFavorite(recipeId, isFavorite);
        if (showFeedback) {
          _showSnackBar(
            isFavorite
                ? 'Added ${recipeTitle ?? 'this recipe'} to favorites.'
                : 'Removed ${recipeTitle ?? 'this recipe'} from favorites.',
          );
        }
        return true;
      }

      if (response.statusCode == 401) {
        await _handleUnauthorized();
      } else if (showFeedback) {
        final String reason =
            _extractError(response.body) ?? _genericErrorMessage;
        _showSnackBar(reason, isError: true);
      }
    } catch (_) {
      if (showFeedback) {
        _showSnackBar(_genericErrorMessage, isError: true);
      }
    }

    return false;
  }

  void _updateRecipeFavorite(String recipeId, bool isFavorite) {
    if (!mounted) {
      return;
    }

    setState(() {
      _recipes = _recipes
          .map(
            (Recipe recipe) => recipe.id == recipeId
                ? recipe.copyWith(isFavorite: isFavorite)
                : recipe,
          )
          .toList();
    });
  }

  Widget _buildCategoriesView() {
    if (_recipes.isEmpty) {
      return Center(
        child: Text(
          _isFetchingRecipes
              ? 'Loading categories…'
              : 'No categories available yet.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    final Map<String, List<Recipe>> categories = <String, List<Recipe>>{};
    for (final Recipe recipe in _recipes) {
      final String key = recipe.category?.isNotEmpty == true
          ? recipe.category!
          : 'Uncategorized';
      categories.putIfAbsent(key, () => <Recipe>[]).add(recipe);
    }

    final List<MapEntry<String, List<Recipe>>> entries =
        categories.entries.toList()..sort(
          (
            MapEntry<String, List<Recipe>> a,
            MapEntry<String, List<Recipe>> b,
          ) => a.key.toLowerCase().compareTo(b.key.toLowerCase()),
        );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        final MapEntry<String, List<Recipe>> entry = entries[index];
        final TextStyle recipeTitleStyle =
            Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12) ??
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: const Icon(Icons.local_dining_rounded),
            title: Text(entry.key),
            subtitle: Text('${entry.value.length} recipe(s)'),
            children: entry.value
                .map(
                  (Recipe recipe) => _buildDismissibleRecipe(
                    recipe,
                    keySuffix: 'category-${entry.key}',
                    child: ListTile(
                      leading:
                          recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                recipe.imageUrl!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (
                                      BuildContext context,
                                      Object error,
                                      StackTrace? stackTrace,
                                    ) => const _ImagePlaceholder(),
                              ),
                            )
                          : const SizedBox(
                              width: 48,
                              height: 48,
                              child: _ImagePlaceholder(),
                            ),
                      title:
                          Text(recipe.title, style: recipeTitleStyle),
                      subtitle: _metaSummary(recipe) != null
                          ? Text(_metaSummary(recipe)!)
                          : null,
                      onTap: () => _openRecipeDetail(recipe),
                      trailing: IconButton(
                        icon: Icon(
                          recipe.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                        ),
                        color: recipe.isFavorite
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.outline,
                        tooltip: recipe.isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: recipe.id.trim().isEmpty
                            ? null
                            : () {
                                _toggleFavoriteForRecipe(recipe);
                              },
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesView() {
    final List<Recipe> favorites = _recipes
        .where((Recipe recipe) => recipe.isFavorite)
        .toList();

    if (_isFetchingRecipes && favorites.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => _fetchRecipes(ignoreCache: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: favorites.isEmpty ? 1 : favorites.length,
        itemBuilder: (BuildContext context, int index) {
          if (favorites.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 64.0),
              child: Center(
                child: Text(
                  'No favorites yet. Tap the star on a recipe to save it here.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final Recipe recipe = favorites[index];
          return _buildDismissibleRecipe(
            recipe,
            keySuffix: 'favorite',
            child: _RecipeListItem(
              recipe: recipe,
              onTap: () => _openRecipeDetail(recipe),
              onToggleFavorite: recipe.id.trim().isEmpty
                  ? null
                  : () {
                      _toggleFavoriteForRecipe(recipe);
                    },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountView() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: <Widget>[
        Center(
          child: CircleAvatar(
            radius: 38,
            backgroundColor: scheme.secondary.withValues(
              alpha: _isDarkTheme ? 0.24 : 0.16,
            ),
            child: Icon(
              Icons.person_rounded,
              size: 44,
              color: scheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(child: Text('Logged in as', style: theme.textTheme.titleMedium)),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _currentUserEmail ?? 'Loading profile…',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Appearance', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Switch between dark and light themes.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SegmentedButton<ThemeMode>(
                  segments: const <ButtonSegment<ThemeMode>>[
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                      label: Text('Dark'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded),
                      label: Text('Light'),
                    ),
                  ],
                  selected: <ThemeMode>{_currentThemeMode},
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    textStyle: WidgetStateProperty.all<TextStyle?>(
                      theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  onSelectionChanged: (Set<ThemeMode> selection) {
                    if (selection.isEmpty) {
                      return;
                    }
                    _updateThemePreference(selection.first);
                  },
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const Icon(Icons.bookmark_added_rounded),
            title: const Text('Recipes saved'),
            trailing: Text('${_recipes.length}'),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const Icon(Icons.star_rounded),
            title: const Text('Favorites saved'),
            trailing: Text(
              '${_recipes.where((Recipe recipe) => recipe.isFavorite).length}',
            ),
          ),
        ),
        if (_biometricSupported && _biometricEnabled)
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: ListTile(
              leading: const Icon(Icons.face_retouching_natural_rounded),
              title: const Text('Face ID'),
              subtitle: const Text('Quick sign-in is enabled'),
              trailing: TextButton(
                onPressed: _isBiometricAuthenticating
                    ? null
                    : _promptDisableBiometrics,
                child: const Text('Disable'),
              ),
            ),
          ),
        FilledButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign out'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
        ),
      ],
    );
  }

  String? _metaSummary(Recipe recipe) {
    final List<String> parts = <String>[];
    if (recipe.prepTime != null) {
      parts.add('Prep ${recipe.prepTime}');
    }
    if (recipe.totalTime != null) {
      parts.add('Total ${recipe.totalTime}');
    }
    if (recipe.servings != null) {
      parts.add('Serves ${recipe.servings}');
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' • ');
  }

  Widget _buildDismissibleRecipe(
    Recipe recipe, {
    required Widget child,
    String keySuffix = 'main',
  }) {
    return Dismissible(
      key: ValueKey<String>('recipe-${recipe.id}-$keySuffix'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(context),
      confirmDismiss: (_) async {
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Remove recipe?'),
              content: const Text(
                'Deleting this recipe cannot be undone. Do you want to continue?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );

        if (confirmed != true) {
          return false;
        }
        return _deleteRecipe(recipe);
      },
      child: child,
    );
  }

  Widget _buildDismissBackground(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: scheme.error,
      child: Icon(Icons.delete_forever_rounded, color: scheme.onError),
    );
  }
}

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.summary,
    required this.prepTime,
    required this.totalTime,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.raw,
    this.note,
    this.category,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String? imageUrl;
  final String? summary;
  final String? prepTime;
  final String? totalTime;
  final String? servings;
  final List<String> ingredients;
  final List<String> instructions;
  final Map<String, dynamic> raw;
  final String? note;
  final String? category;
  final bool isFavorite;

  bool get hasMeta => prepTime != null || totalTime != null || servings != null;

  List<Uri> get originalUris {
    final Set<String> seen = <String>{};
    final List<Uri> result = <Uri>[];

    void addUri(Uri? uri) {
      if (uri == null || !uri.hasScheme) {
        return;
      }
      final String scheme = uri.scheme.toLowerCase();
      if (scheme != 'http' && scheme != 'https') {
        return;
      }
      // Filter out malformed URLs (missing host or invalid format)
      if (uri.host.isEmpty || uri.host == '') {
        print('iOS: Skipping malformed URL: $uri');
        return;
      }
      final String key = uri.toString();
      if (seen.add(key)) {
        result.add(uri);
      }
    }

    void handle(dynamic candidate) {
      if (candidate == null) {
        return;
      }

      if (candidate is Map<dynamic, dynamic>) {
        final List<dynamic> nestedValues = <dynamic>[
          candidate['url'],
          candidate['link'],
          candidate['href'],
          candidate['source'],
          candidate['@id'],
        ]..removeWhere((dynamic value) => value == null);
        for (final dynamic nested in nestedValues) {
          handle(nested);
        }
        return;
      }

      if (candidate is Iterable<dynamic> && candidate is! String) {
        for (final dynamic item in candidate) {
          handle(item);
        }
        return;
      }

      final String? value = _stringOrNull(candidate);
      if (value == null) {
        return;
      }

      final String normalized = value.trim();
      if (normalized.isEmpty) {
        return;
      }

      print('iOS: Processing URL candidate: "$normalized"');

      final Uri? direct = Uri.tryParse(normalized);
      addUri(direct);

      // Only try to add protocol for very specific cases where we're confident it's a domain
      if (!(normalized.contains('://')) &&
          !normalized.startsWith('/') &&
          !normalized.startsWith('#') &&
          normalized.contains('.') &&
          !normalized.contains(' ')) {
        addUri(Uri.tryParse('https://$normalized'));
      }
    }

    // Prioritize complete URLs from the API
    final List<dynamic> candidates = <dynamic>[
      raw['originalURL'],
      raw['original_url'],
      raw['originalUrl'],
      raw['sourceURL'],
      raw['source_url'],
      raw['canonicalUrl'],
      raw['canonical_url'],
      // Only include these if they look like complete URLs
      raw['source'],
      raw['canonical'],
    ];

    for (final dynamic candidate in candidates) {
      handle(candidate);
    }

    return result;
  }

  String? get originalUrl =>
      originalUris.isEmpty ? null : originalUris.first.toString();

  static List<Recipe> listFromAny(dynamic data) {
    if (data is List<dynamic>) {
      return data
          .map((dynamic item) => Recipe.fromJson(_coerceMap(item)))
          .whereType<Recipe>()
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final List<dynamic>? items = _extractList(data);
      if (items != null) {
        return items
            .map((dynamic item) => Recipe.fromJson(_coerceMap(item)))
            .whereType<Recipe>()
            .toList();
      }
    }

    return <Recipe>[];
  }

  static Map<String, dynamic>? _coerceMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return null;
  }

  static List<dynamic>? _extractList(Map<String, dynamic> data) {
    for (final String key in <String>['recipes', 'data', 'items']) {
      final dynamic value = data[key];
      if (value is List<dynamic>) {
        return value;
      }
    }
    return null;
  }

  factory Recipe.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('Recipe json cannot be null');
    }

    final String title = (json['title'] ?? json['name'] ?? 'Untitled Recipe')
        .toString();
    final String idCandidate =
        (json['id'] ?? json['recipe_id'] ?? json['uuid'] ?? title).toString();
    final Object? imageValue =
        json['image'] ?? json['image_url'] ?? json['thumbnail'];
    final String? imageUrl = imageValue?.toString();
    final String? summary =
        (json['summary'] ?? json['description'] ?? json['details'])?.toString();
    final String? prepTime = _stringFrom(json, <String>[
      'prep_time',
      'prepTime',
      'prep_minutes',
      'prepTimeMinutes',
      'preparation_time',
      'preparationTime',
    ], treatAsDuration: true);
    final String? totalTime = _stringFrom(json, <String>[
      'total_time',
      'totalTime',
      'time',
      'cook_time',
      'cookTime',
      'duration',
    ], treatAsDuration: true);
    final String? servings = _stringFrom(json, <String>[
      'servings',
      'yield',
      'yields',
      'servings_count',
      'servingsCount',
      'portion',
      'portions',
    ]);

    final List<String> ingredients = _stringListFrom(json['ingredients']);
    final List<String> instructions = _stringListFrom(json['instructions']);
    final String? note = _stringOrNull(json['note']);
    final String? category = _stringOrNull(
      json['category'] ?? json['Category'] ?? json['type'],
    );
    final dynamic favoriteValue = json['isFavorite'];
    final bool isFavorite =
        favoriteValue == true ||
        (favoriteValue is String && favoriteValue.toLowerCase() == 'true');

    if (instructions.isEmpty) {
      final String? instructionText = json['instruction']?.toString();
      if (instructionText != null && instructionText.isNotEmpty) {
        instructions.add(instructionText);
      }
    }

    return Recipe(
      id: idCandidate,
      title: title,
      imageUrl: imageUrl,
      summary: summary,
      prepTime: prepTime,
      totalTime: totalTime,
      servings: servings,
      ingredients: ingredients,
      instructions: instructions,
      raw: json,
      note: note,
      category: category,
      isFavorite: isFavorite,
    );
  }

  Recipe copyWith({
    String? title,
    List<String>? instructions,
    List<String>? ingredients,
    String? note,
    String? category,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id,
      title: title ?? this.title,
      imageUrl: imageUrl,
      summary: summary,
      prepTime: prepTime,
      totalTime: totalTime,
      servings: servings,
      ingredients: ingredients != null
          ? List<String>.from(ingredients)
          : List<String>.from(this.ingredients),
      instructions: instructions != null
          ? List<String>.from(instructions)
          : List<String>.from(this.instructions),
      raw: raw,
      note: note ?? this.note,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static List<String> _stringListFrom(dynamic value) {
    if (value is List<dynamic>) {
      return value.map((dynamic item) => item.toString()).toList();
    }

    if (value is String && value.isNotEmpty) {
      return value
          .split(RegExp(r'\r?\n'))
          .map((String line) => line.trim())
          .toList();
    }

    return <String>[];
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    final String trimmed = value.toString().trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _stringFrom(
    Map<String, dynamic> json,
    List<String> keys, {
    bool treatAsDuration = false,
  }) {
    for (final String key in keys) {
      final dynamic value = _lookupValue(json, key);
      final String? normalized = _normalizeValue(
        value,
        treatAsDuration: treatAsDuration,
      );
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return null;
  }

  static dynamic _lookupValue(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) {
      return json[key];
    }

    for (final String containerKey in <String>['meta', 'details', 'info']) {
      final dynamic container = json[containerKey];
      if (container is Map<String, dynamic> && container.containsKey(key)) {
        return container[key];
      }
    }

    return null;
  }

  static String? _normalizeValue(
    dynamic value, {
    bool treatAsDuration = false,
  }) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      final String numericString = value == value.roundToDouble()
          ? value.toInt().toString()
          : '$value';
      return treatAsDuration ? '$numericString min' : numericString;
    }

    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }

      if (treatAsDuration && RegExp(r'^\d+(?:\.\d+)?$').hasMatch(trimmed)) {
        // Append minutes if the value looks purely numeric.
        return '$trimmed min';
      }

      return trimmed;
    }

    return value.toString();
  }

  // Note: slug-related helpers and fields removed. API calls use `id`.
}

class _PendingRecipeListItem extends StatelessWidget {
  const _PendingRecipeListItem({
    required this.url,
    required this.position,
    required this.total,
    required this.status,
    required this.onRemove,
  });

  final String url;
  final int position;
  final int total;
  final _PendingRecipeStatus status;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isSaving = status == _PendingRecipeStatus.saving;
    final bool isAwaiting = status == _PendingRecipeStatus.awaitingImport;
    final bool canRemove = !isSaving;
    final String statusText;
    if (isSaving) {
      statusText = 'Downloading…';
    } else if (isAwaiting) {
      statusText = 'Finishing up…';
    } else if (total > 1) {
      statusText = 'Queued (${position + 1} of $total)';
    } else {
      statusText = 'Queued';
    }
    final Widget leading;
    if (isSaving) {
      leading = const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    } else if (isAwaiting) {
      leading = Icon(
        Icons.hourglass_bottom_rounded,
        size: 32,
        color: scheme.primary,
      );
    } else {
      leading = Icon(
        Icons.downloading_rounded,
        size: 32,
        color: scheme.primary,
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 184,
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: scheme.surfaceContainerHigh,
                child: Center(child: leading),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Download in progress',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Remove from queue',
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          onPressed: canRemove ? onRemove : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      url,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeListItem extends StatelessWidget {
  const _RecipeListItem({
    required this.recipe,
    required this.onTap,
    this.onToggleFavorite,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    Widget? buildFavoriteButton() {
      if (onToggleFavorite == null) {
        return null;
      }
      return IconButton(
        onPressed: onToggleFavorite,
        icon: Icon(
          recipe.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
        ),
        color:
            recipe.isFavorite ? scheme.secondary : scheme.onSurfaceVariant,
        iconSize: 26,
        splashRadius: 24,
        tooltip:
            recipe.isFavorite ? 'Remove from favorites' : 'Add to favorites',
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      );
    }

    Widget buildDetailsSection() {
      final Widget favoriteButton = buildFavoriteButton() ??
          const SizedBox.shrink();

      if (recipe.hasMeta) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _RecipeMetaRow(recipe: recipe, dense: true),
            ),
            if (onToggleFavorite != null) ...<Widget>[
              const SizedBox(width: 12),
              favoriteButton,
            ],
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSupportingContent(theme, scheme),
          if (onToggleFavorite != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.topRight,
                child: favoriteButton,
              ),
            ),
        ],
      );
    }

    Widget buildRecipeImage() {
      final Widget imageContent;
      if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
        imageContent = Image.network(
          recipe.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) {
            return const _ImagePlaceholder();
          },
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }
            return const _ImagePlaceholder(isLoading: true);
          },
        );
      } else {
        imageContent = const _ImagePlaceholder();
      }

      return SizedBox(
        width: 120,
        child: AspectRatio(aspectRatio: 1, child: imageContent),
      );
    }

    final TextStyle titleStyle = theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ) ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        );

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 208,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  recipe.title,
                  style: titleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildRecipeImage(),
                      const SizedBox(width: 20),
                      Expanded(child: buildDetailsSection()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportingContent(ThemeData theme, ColorScheme scheme) {
    if (recipe.hasMeta) {
      return _RecipeMetaRow(recipe: recipe, dense: true);
    }

    final TextStyle? style = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.4,
    );

    if (recipe.summary != null && recipe.summary!.isNotEmpty) {
      return Text(
        recipe.summary!,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    if (recipe.ingredients.isNotEmpty) {
      return Text(
        recipe.ingredients.take(3).join(', '),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    return Text('Tap to view details', style: style);
  }
}

class _RecipeMetaRow extends StatelessWidget {
  const _RecipeMetaRow({
    required this.recipe,
    this.textStyle,
    this.backgroundColor,
    this.dense = false,
  });

  final Recipe recipe;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle baseStyle =
        textStyle ??
        theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14);
    final double baseFontSize = baseStyle.fontSize ?? 14;
    final TextStyle effectiveStyle = baseStyle.copyWith(
      fontSize: dense ? baseFontSize - 1 : baseFontSize,
      fontWeight: dense
          ? FontWeight.w600
          : (baseStyle.fontWeight ?? FontWeight.w500),
      height: 1.3,
      color: textStyle?.color ?? scheme.onSurfaceVariant,
    );

    final List<Widget> rows = <Widget>[];

    void addRow(IconData icon, String label, String? value) {
      if (value == null || value.isEmpty) {
        return;
      }
      rows.add(
        _buildRow(
          context,
          icon: icon,
          label: label,
          value: value,
          style: effectiveStyle,
          iconSize: dense ? 16 : 18,
        ),
      );
    }

    addRow(Icons.timer_outlined, 'Prep', recipe.prepTime);
    addRow(Icons.schedule_rounded, 'Total', recipe.totalTime);
    addRow(Icons.restaurant_menu_rounded, 'Serves', recipe.servings);

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final double verticalGap = dense ? 6 : 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int index = 0; index < rows.length; index++) ...<Widget>[
          if (index > 0) SizedBox(height: verticalGap),
          rows[index],
        ],
      ],
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required TextStyle style,
    required double iconSize,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double spacing = dense ? 8 : 10;
    final Widget rowContent = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          size: iconSize,
          color: backgroundColor != null
              ? scheme.secondary
              : scheme.onSurfaceVariant,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            '$label $value',
            style: style,
            maxLines: dense ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (backgroundColor != null) {
      final EdgeInsets padding = dense
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      return Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(dense ? 14 : 18),
        ),
        child: rowContent,
      );
    }

    return SizedBox(width: double.infinity, child: rowContent);
  }
}

class _RecipeHeroImage extends StatelessWidget {
  const _RecipeHeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double computedHeight = screenSize.height * 0.2;
    final double height = computedHeight < 140
        ? 140
        : computedHeight > 260
        ? 260
        : computedHeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) =>
                  const _ImagePlaceholder(),
          loadingBuilder:
              (
                BuildContext context,
                Widget child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }
                return const _ImagePlaceholder(isLoading: true);
              },
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.isLoading = false});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          isLoading ? Icons.hourglass_bottom : Icons.restaurant,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({
    required this.recipe,
    required this.authToken,
    required this.onFavoriteToggle,
    required this.baseUrl,
    super.key,
  });

  final Recipe recipe;
  final String authToken;
  final Future<bool> Function(String recipeId, bool isFavorite)
  onFavoriteToggle;
  final String baseUrl;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  static const String _genericErrorMessage =
      'An error occurred. Please try again later.';
  late Recipe _recipe;
  bool _isFavorite = false;
  bool _isFavoriteUpdating = false;
  bool _recipeChanged = false;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    _isFavorite = widget.recipe.isFavorite;
  }

  bool get _canEditRecipe => _recipe.id.trim().isNotEmpty;

  Future<void> _openRecipeEditOverlay() async {
    if (!_canEditRecipe) {
      _showSnackBar(
        'Editing is unavailable because this recipe is missing a unique identifier.',
        isError: true,
      );
      return;
    }

    final _RecipeEditResult? result =
        await showModalBottomSheet<_RecipeEditResult>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return _RecipeEditSheet(
              initialTitle: _recipe.title,
              initialInstructions: _recipe.instructions,
              initialIngredients: _recipe.ingredients,
              baseUrl: widget.baseUrl,
              recipeId: _recipe.id,
              authToken: widget.authToken,
              initialCategory: _recipe.category,
            );
          },
        );

    if (result == null) {
      return;
    }

    if (result.requiresReauth) {
      await _handleUnauthorizedFromChild();
      return;
    }

    if (result.title != null &&
        result.instructions != null &&
        result.ingredients != null) {
      setState(() {
        _recipe = _recipe.copyWith(
          title: result.title,
          instructions: result.instructions,
          ingredients: result.ingredients,
          category: result.category,
        );
        _recipeChanged = true;
      });
      _showSnackBar('Recipe updated.');
    }
  }

  Future<void> _toggleFavorite() async {
    final String recipeId = _recipe.id.trim();
    if (recipeId.isEmpty) {
      _showSnackBar(
        'Unable to update favorites for this recipe.',
        isError: true,
      );
      return;
    }
    if (_isFavoriteUpdating) {
      return;
    }
    setState(() {
      _isFavoriteUpdating = true;
    });
    final bool desired = !_isFavorite;
    final bool success = await widget.onFavoriteToggle(recipeId, desired);
    if (!mounted) {
      return;
    }
    setState(() {
      _isFavoriteUpdating = false;
      if (success) {
        _isFavorite = desired;
        _recipe = _recipe.copyWith(isFavorite: desired);
      }
    });
    _showSnackBar(
      success
          ? (desired ? 'Added to favorites.' : 'Removed from favorites.')
          : _genericErrorMessage,
      isError: !success,
    );
  }

  bool get _shouldPropagateChanges => _recipeChanged;

  Future<void> _handleUnauthorizedFromChild() async {
    _showSnackBar('Session expired. Please login again.', isError: true);
    Navigator.of(context).pop(true);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe'),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(_shouldPropagateChanges),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _recipe.id.trim().isEmpty || _isFavoriteUpdating
                ? null
                : _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            ),
            color: _isFavorite
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
          IconButton(
            onPressed: _canEditRecipe ? _openRecipeEditOverlay : null,
            icon: const Icon(Icons.edit),
            tooltip: _canEditRecipe
                ? 'Edit recipe'
                : 'Editing unavailable for this recipe',
          ),
        ],
      ),
      body: _RecipeDetailsBody(recipe: _recipe),
    );
  }
}

class _RecipeDetailsBody extends StatelessWidget {
  const _RecipeDetailsBody({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Uri> originalUris = recipe.originalUris;
    final TextStyle titleStyle = theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ) ??
        theme.textTheme.titleLarge ??
        const TextStyle(fontSize: 22, fontWeight: FontWeight.w700);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            recipe.title,
            style: titleStyle,
            softWrap: true,
          ),
          if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            _RecipeHeroImage(imageUrl: recipe.imageUrl!),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 16),
          if (recipe.hasMeta)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _RecipeMetaRow(
                recipe: recipe,
                textStyle: theme.textTheme.bodyMedium,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          if (originalUris.isNotEmpty) ...<Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final ScaffoldMessengerState? messenger =
                      ScaffoldMessenger.maybeOf(context);
                  void showError() {
                    messenger?.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Unable to open the original recipe link.',
                        ),
                      ),
                    );
                  }

                  for (final Uri uri in originalUris) {
                    try {
                      final List<LaunchMode> modes = <LaunchMode>[
                        LaunchMode.externalApplication,
                        LaunchMode.platformDefault,
                        LaunchMode.externalNonBrowserApplication,
                      ];

                      for (final LaunchMode mode in modes) {
                        print('iOS: Trying to launch $uri with mode: $mode');
                        try {
                          final bool launched = await launchUrl(
                            uri,
                            mode: mode,
                          );
                          if (launched) {
                            print(
                              'iOS: Successfully launched with mode: $mode',
                            );
                            return;
                          }
                        } catch (modeError) {
                          print('iOS: Mode $mode failed: $modeError');
                        }
                      }
                    } catch (e) {
                      print('iOS: Launch error for $uri: $e');
                    }
                  }
                  showError();
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open original recipe'),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (recipe.summary != null && recipe.summary!.isNotEmpty) ...<Widget>[
            Text('Summary', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(recipe.summary!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
          ],
          if (recipe.ingredients.isNotEmpty) ...<Widget>[
            Text('Ingredients', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...recipe.ingredients.map(
              (String ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text('• $ingredient'),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (recipe.instructions.isNotEmpty) ...<Widget>[
            Text('Instructions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...recipe.instructions.map(
              (String instruction) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(instruction),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ExpansionTile(
            title: const Text('View raw data'),
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  const JsonEncoder.withIndent('  ').convert(recipe.raw),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipeEditResult {
  const _RecipeEditResult({
    this.title,
    this.instructions,
    this.ingredients,
    this.category,
    this.requiresReauth = false,
  });

  final String? title;
  final List<String>? instructions;
  final List<String>? ingredients;
  final String? category;
  final bool requiresReauth;
}

class _RecipeEditSheet extends StatefulWidget {
  const _RecipeEditSheet({
    required this.initialTitle,
    required this.initialInstructions,
    required this.initialIngredients,
    required this.baseUrl,
    required this.recipeId,
    required this.authToken,
    required this.initialCategory,
  });

  final String initialTitle;
  final List<String> initialInstructions;
  final List<String> initialIngredients;
  final String baseUrl;
  final String recipeId;
  final String authToken;
  final String? initialCategory;

  @override
  State<_RecipeEditSheet> createState() => _RecipeEditSheetState();
}

class _RecipeEditSheetState extends State<_RecipeEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _ingredientsController;
  late final String _initialNormalizedInstructions;
  late final String _initialNormalizedIngredients;
  late final String _initialNormalizedCategory;
  String? _selectedCategory;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _instructionsController = TextEditingController(
      text: _instructionsTextFromList(widget.initialInstructions),
    );
    _ingredientsController = TextEditingController(
      text: _ingredientsTextFromList(widget.initialIngredients),
    );
    _initialNormalizedInstructions = _normalizeInstructionsText(
      _instructionsController.text,
    );
    _initialNormalizedIngredients = _normalizeIngredientsText(
      _ingredientsController.text,
    );
    final String? initialLc = widget.initialCategory?.toLowerCase();
    const List<String> allowed = <String>[
      'breakfast',
      'dinner',
      'baking',
      'other',
    ];
    final String normalized = (initialLc != null && allowed.contains(initialLc))
        ? initialLc
        : 'other';
    _selectedCategory = normalized;
    _initialNormalizedCategory = normalized;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  String _instructionsTextFromList(List<String> instructions) {
    if (instructions.isEmpty) {
      return '';
    }
    return instructions.join('\n');
  }

  String _ingredientsTextFromList(List<String> ingredients) {
    if (ingredients.isEmpty) {
      return '';
    }
    return ingredients.join('\n');
  }

  List<String> _instructionListFromText(String value) {
    return value
        .split(RegExp(r'\r?\n'))
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();
  }

  List<String> _ingredientListFromText(String value) {
    return value
        .split(RegExp(r'\r?\n'))
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();
  }

  String _normalizeInstructionsText(String value) {
    return _instructionListFromText(value).join('\n');
  }

  String _normalizeIngredientsText(String value) {
    return _ingredientListFromText(value).join('\n');
  }

  bool get _hasChanges {
    final String trimmedTitle = _titleController.text.trim();
    final String normalizedInstructions = _normalizeInstructionsText(
      _instructionsController.text,
    );
    final String normalizedIngredients = _normalizeIngredientsText(
      _ingredientsController.text,
    );
    return trimmedTitle != widget.initialTitle.trim() ||
        normalizedInstructions != _initialNormalizedInstructions ||
        normalizedIngredients != _initialNormalizedIngredients ||
        (_selectedCategory ?? '') != _initialNormalizedCategory;
  }

  Future<void> _handleCancel() async {
    Navigator.of(context).pop();
  }

  Future<void> _handleSave() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _error = 'Title is required.';
      });
      return;
    }

    final List<String> instructions = _instructionListFromText(
      _instructionsController.text,
    );
    final List<String> ingredients = _ingredientListFromText(
      _ingredientsController.text,
    );
    final String category = (_selectedCategory ?? 'other').trim().toLowerCase();

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final http.Response response = await http.patch(
        Uri.parse('${widget.baseUrl}/recipes/id/${widget.recipeId}'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}',
        },
        body: jsonEncode(<String, dynamic>{
          'title': title,
          'instructions': instructions,
          'ingredients': ingredients,
          'category': category,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (!mounted) {
          return;
        }

        Navigator.of(context).pop(
          _RecipeEditResult(
            title: title,
            instructions: instructions,
            ingredients: ingredients,
            category: category,
          ),
        );
        return;
      }

      if (response.statusCode == 401) {
        if (!mounted) {
          return;
        }
        Navigator.of(
          context,
        ).pop(const _RecipeEditResult(requiresReauth: true));
        return;
      }

      setState(() {
        _isSaving = false;
        _error = _extractError(response.body);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _error = 'Unable to save changes right now. Please try again.';
      });
    }
  }

  String? _extractError(String body) {
    if (body.isEmpty) {
      return 'Unable to save changes right now. Please try again.';
    }
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        for (final String key in <String>['message', 'error', 'detail']) {
          final dynamic value = decoded[key];
          if (value is String && value.trim().isNotEmpty) {
            return _friendlyError(value);
          }
        }
      }
    } catch (_) {
      // Fall through to friendly error formatting.
    }
    return _friendlyError(body);
  }

  String _friendlyError(String? message) {
    final String trimmed = (message ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Unable to save changes right now. Please try again.';
    }
    if (trimmed.length > 120 || trimmed.contains('\n')) {
      return 'Unable to save changes right now. Please try again.';
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return FractionallySizedBox(
      heightFactor: 0.95,
      child: Material(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        color: theme.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: viewInsets > 0 ? viewInsets : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      onPressed: _isSaving ? null : _handleCancel,
                      child: const Text('Cancel'),
                    ),
                    Text('Edit recipe', style: theme.textTheme.titleMedium),
                    FilledButton(
                      onPressed: _isSaving || !_hasChanges ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextField(
                          controller: _titleController,
                          enabled: !_isSaving,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String?>(
                          value: _selectedCategory,
                          items: const <DropdownMenuItem<String?>>[
                            DropdownMenuItem<String?>(
                              value: 'other',
                              child: Text('Other'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'breakfast',
                              child: Text('Breakfast'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'dinner',
                              child: Text('Dinner'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'baking',
                              child: Text('Baking'),
                            ),
                          ],
                          onChanged: _isSaving
                              ? null
                              : (String? value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _ingredientsController,
                          enabled: !_isSaving,
                          keyboardType: TextInputType.multiline,
                          minLines: 6,
                          maxLines: null,
                          decoration: const InputDecoration(
                            labelText: 'Ingredients',
                            alignLabelWithHint: true,
                            helperText:
                                'Enter one ingredient per line. Blank lines are ignored.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _instructionsController,
                          enabled: !_isSaving,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          minLines: 6,
                          maxLines: null,
                          decoration: const InputDecoration(
                            labelText: 'Instructions',
                            alignLabelWithHint: true,
                            helperText:
                                'Enter one step per line. Blank lines are ignored.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_error != null) ...<Widget>[
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
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

class RecipeSearchDelegate extends SearchDelegate<Recipe?> {
  RecipeSearchDelegate({required this.search});

  static const String _genericErrorMessage =
      'An error occurred. Please try again later.';

  final Future<List<Recipe>> Function(String query) search;

  Future<List<Recipe>>? _currentSearch;
  String _lastQuery = '';

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query.isEmpty) {
      return null;
    }
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
        tooltip: 'Clear search',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
      tooltip: 'Back',
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchBody(context);

  Widget _buildSearchBody(BuildContext context) {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return _SearchPlaceholder(
        icon: Icons.search,
        message: 'Start typing to find saved recipes.',
      );
    }

    if (trimmed.length < 2) {
      return _SearchPlaceholder(
        icon: Icons.keyboard,
        message: 'Enter at least 2 characters to search.',
      );
    }

    if (trimmed != _lastQuery) {
      _lastQuery = trimmed;
      _currentSearch = search(trimmed);
    }

    return FutureBuilder<List<Recipe>>(
      future: _currentSearch,
      builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const _SearchPlaceholder(
            icon: Icons.error_outline,
            message: _genericErrorMessage,
          );
        }

        final List<Recipe> results = snapshot.data ?? <Recipe>[];
        if (results.isEmpty) {
          return _SearchPlaceholder(
            icon: Icons.sentiment_dissatisfied,
            message: 'No recipes found for "$trimmed".',
          );
        }

        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            final Recipe recipe = results[index];
            final TextStyle recipeTitleStyle =
                Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12) ??
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
            return ListTile(
              leading: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        recipe.imageUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) => const _ImagePlaceholder(),
                      ),
                    )
                  : const SizedBox(
                      width: 48,
                      height: 48,
                      child: _ImagePlaceholder(),
                    ),
              title: Text(recipe.title, style: recipeTitleStyle),
              subtitle: _formatMeta(recipe),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    recipe.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: recipe.isFavorite
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.outline,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              onTap: () => close(context, recipe),
            );
          },
        );
      },
    );
  }

  Widget? _formatMeta(Recipe recipe) {
    final List<String> parts = <String>[];
    if (recipe.category != null && recipe.category!.isNotEmpty) {
      parts.add(recipe.category!);
    }
    if (recipe.prepTime != null) {
      parts.add('Prep ${recipe.prepTime}');
    }
    if (recipe.totalTime != null) {
      parts.add('Total ${recipe.totalTime}');
    }
    if (recipe.servings != null) {
      parts.add('Serves ${recipe.servings}');
    }
    if (parts.isEmpty) {
      return null;
    }
    return Text(parts.join(' • '));
  }
}

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
