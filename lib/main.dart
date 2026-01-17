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

part 'core/constants.dart';
part 'theme/app_theme.dart';
part 'app/share_handler_app.dart';
part 'app/share_display_page.dart';

part 'features/categories/categories.dart';

part 'features/recipes/pending_shared/pending_shared_models.dart';
part 'features/recipes/models/recipe.dart';
part 'features/recipes/widgets/recipe_list_items.dart';
part 'features/recipes/pages/recipe_detail_page.dart';
part 'features/recipes/recipes_tab.dart';

part 'features/search/recipe_search_delegate.dart';
part 'features/favorites/favorites_tab.dart';
part 'features/account/account_tab.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final ThemeMode initialThemeMode = _themeModeFromStored(
    prefs.getString(_themePreferenceKey),
  );
  runApp(ShareHandlerApp(initialThemeMode: initialThemeMode));
}
