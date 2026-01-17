part of 'package:iosapp/main.dart';

extension _ShareDisplayAccountTab on _ShareDisplayPageState {
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

}
