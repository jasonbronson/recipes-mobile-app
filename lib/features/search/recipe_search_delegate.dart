part of 'package:iosapp/main.dart';

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
