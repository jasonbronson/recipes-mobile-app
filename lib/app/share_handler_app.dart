part of 'package:iosapp/main.dart';

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
