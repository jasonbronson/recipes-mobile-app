part of 'package:iosapp/main.dart';

class _CallbackNavigatorObserver extends NavigatorObserver {
  _CallbackNavigatorObserver({required this.onChange});

  final VoidCallback onChange;

  void _notify() {
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange());
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _notify();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _notify();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _notify();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _notify();
  }
}

class RecipesScope extends InheritedWidget {
  const RecipesScope({
    required this.recipes,
    required this.isFetchingRecipes,
    required this.onOpenRecipe,
    required this.onToggleFavorite,
    required this.onDeleteRecipe,
    required super.child,
    super.key,
  });

  final List<Recipe> recipes;
  final bool isFetchingRecipes;
  final Future<void> Function(Recipe recipe) onOpenRecipe;
  final Future<void> Function(Recipe recipe) onToggleFavorite;
  final Future<bool> Function(Recipe recipe) onDeleteRecipe;

  static RecipesScope of(BuildContext context) {
    final RecipesScope? scope =
        context.dependOnInheritedWidgetOfExactType<RecipesScope>();
    assert(scope != null, 'RecipesScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(RecipesScope oldWidget) {
    return recipes != oldWidget.recipes ||
        isFetchingRecipes != oldWidget.isFetchingRecipes;
  }
}

String _categoryKeyFrom(String? value) {
  final String trimmed = (value ?? '').trim();
  return trimmed.isEmpty ? 'Uncategorized' : trimmed;
}

bool _isDinnerCategory(String category) {
  return category.trim().toLowerCase() == 'dinner';
}

bool _recipeMatchesTextTerms(
  Recipe recipe, {
  List<String> includeAny = const <String>[],
  List<String> excludeAny = const <String>[],
}) {
  final String haystack = <String>[
    recipe.title,
    recipe.ingredients.join('\n'),
  ].join('\n').toLowerCase();

  if (includeAny.isNotEmpty) {
    final bool anyIncluded = includeAny.any(
      (String term) {
        final String needle = term.trim().toLowerCase();
        return needle.isNotEmpty && haystack.contains(needle);
      },
    );
    if (!anyIncluded) {
      return false;
    }
  }

  final bool anyExcluded = excludeAny.any((String term) {
    final String needle = term.trim().toLowerCase();
    return needle.isNotEmpty && haystack.contains(needle);
  });
  return !anyExcluded;
}

class CategoriesHomeScreen extends StatelessWidget {
  const CategoriesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RecipesScope scope = RecipesScope.of(context);
    final List<Recipe> recipes = scope.recipes;
    final ThemeData theme = Theme.of(context);

    if (recipes.isEmpty) {
      if (scope.isFetchingRecipes) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Text(
          'No categories available yet.',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    final Map<String, List<Recipe>> categories = <String, List<Recipe>>{};
    for (final Recipe recipe in recipes) {
      final String key = _categoryKeyFrom(recipe.category);
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
      itemCount: entries.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
            child: Text(
              'Browse by category',
              style: theme.textTheme.titleMedium,
            ),
          );
        }

        final MapEntry<String, List<Recipe>> entry = entries[index - 1];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.local_dining_rounded),
            title: Text(entry.key),
            subtitle: Text('${entry.value.length} recipe(s)'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              if (_isDinnerCategory(entry.key)) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => DinnerSubcategoriesScreen(
                      category: entry.key,
                    ),
                  ),
                );
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => CategoryRecipesScreen(
                    title: entry.key,
                    category: entry.key,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class DinnerSubcategoriesScreen extends StatelessWidget {
  const DinnerSubcategoriesScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    const List<String> chickenTerms = <String>['chicken'];
    const List<String> hamburgerTerms = <String>['hamburger', 'burger', 'beef'];
    const List<String> steakTerms = <String>['steak'];
    const List<String> seafoodTerms = <String>['seafood', 'salmon'];
    const List<String> otherExcludeTerms = <String>[
      ...chickenTerms,
      ...hamburgerTerms,
      ...steakTerms,
      ...seafoodTerms,
    ];

    final List<({String label, List<String> includeAny, List<String> excludeAny})>
        options = <({String label, List<String> includeAny, List<String> excludeAny})>[
      (
        label: 'Chicken',
        includeAny: chickenTerms,
        excludeAny: const <String>[],
      ),
      (
        label: 'Hamburger',
        includeAny: hamburgerTerms,
        excludeAny: const <String>[],
      ),
      (
        label: 'Steak',
        includeAny: steakTerms,
        excludeAny: const <String>[],
      ),
      (
        label: 'Seafood',
        includeAny: seafoodTerms,
        excludeAny: const <String>[],
      ),
      (
        label: 'Other',
        includeAny: const <String>[],
        excludeAny: otherExcludeTerms,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
          child: Text(
            'Dinner',
            style: theme.textTheme.titleMedium,
          ),
        ),
        ...options.map(
          (option) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.restaurant_menu_rounded),
              title: Text(option.label),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => CategoryRecipesScreen(
                      title: 'Dinner • ${option.label}',
                      category: category,
                      includeAny: option.includeAny,
                      excludeAny: option.excludeAny,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryRecipesScreen extends StatelessWidget {
  const CategoryRecipesScreen({
    super.key,
    required this.title,
    required this.category,
    this.includeAny = const <String>[],
    this.excludeAny = const <String>[],
  });

  final String title;
  final String category;
  final List<String> includeAny;
  final List<String> excludeAny;

  @override
  Widget build(BuildContext context) {
    final RecipesScope scope = RecipesScope.of(context);
    final String categoryKey = _categoryKeyFrom(category).toLowerCase();
    final List<String> includeTerms = includeAny
        .map((String value) => value.toLowerCase())
        .toList(growable: false);
    final List<String> excludeTerms = excludeAny
        .map((String value) => value.toLowerCase())
        .toList(growable: false);
    final List<Recipe> matches = scope.recipes.where((Recipe recipe) {
      if (_categoryKeyFrom(recipe.category).toLowerCase() != categoryKey) {
        return false;
      }
      return _recipeMatchesTextTerms(
        recipe,
        includeAny: includeTerms,
        excludeAny: excludeTerms,
      );
    }).toList();

    matches.sort(
      (Recipe a, Recipe b) =>
          a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );

    final int itemCount = matches.isEmpty ? 2 : matches.length + 1;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 160),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          );
        }

        if (matches.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 64.0),
            child: Center(
              child: Text(
                'No recipes found.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final Recipe recipe = matches[index - 1];
        return Dismissible(
          key: ValueKey<String>(
            'recipe-${recipe.id}-category-$categoryKey-${includeAny.join(',')}-${excludeAny.join(',')}',
          ),
          direction: DismissDirection.endToStart,
          background: _dismissBackground(context),
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

            return scope.onDeleteRecipe(recipe);
          },
          child: _RecipeListItem(
            recipe: recipe,
            onTap: () {
              scope.onOpenRecipe(recipe);
            },
            onToggleFavorite: recipe.id.trim().isEmpty
                ? null
                : () {
                    scope.onToggleFavorite(recipe);
                  },
          ),
        );
      },
    );
  }

  Widget _dismissBackground(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: scheme.error,
      child: Icon(Icons.delete_forever_rounded, color: scheme.onError),
    );
  }
}
