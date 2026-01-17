part of 'package:iosapp/main.dart';

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
  final GlobalKey<NavigatorState> _categoriesNavigatorKey =
      GlobalKey<NavigatorState>();
  late final _CallbackNavigatorObserver _categoriesNavigatorObserver;
  bool _categoriesCanPop = false;

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
    _categoriesNavigatorObserver = _CallbackNavigatorObserver(
      onChange: _syncCategoriesCanPop,
    );
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
      token = await _secureStorage
          .read(key: _tokenStorageKey)
          .timeout(const Duration(milliseconds: 250));
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

  void _syncCategoriesCanPop() {
    final bool canPop = _categoriesNavigatorKey.currentState?.canPop() ?? false;
    if (!mounted || _categoriesCanPop == canPop) {
      return;
    }
    setState(() {
      _categoriesCanPop = canPop;
    });
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

    final NavigatorState? categoriesNavigator =
        _categoriesNavigatorKey.currentState;
    final bool interceptBack =
        _selectedTabIndex == 1 && (categoriesNavigator?.canPop() ?? false);

    return PopScope<Object?>(
      canPop: !interceptBack,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        if (interceptBack) {
          categoriesNavigator?.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _selectedTabIndex == 1 && _categoriesCanPop
              ? IconButton(
                  onPressed: () =>
                      _categoriesNavigatorKey.currentState?.maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Back',
                )
              : null,
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
              _syncCategoriesCanPop();
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
    return RecipesScope(
      recipes: _recipes,
      isFetchingRecipes: _isFetchingRecipes,
      onOpenRecipe: _openRecipeDetail,
      onToggleFavorite: _toggleFavoriteForRecipe,
      onDeleteRecipe: _deleteRecipe,
      child: Navigator(
        key: _categoriesNavigatorKey,
        observers: <NavigatorObserver>[_categoriesNavigatorObserver],
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (BuildContext context) => const CategoriesHomeScreen(),
          );
        },
      ),
    );
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
