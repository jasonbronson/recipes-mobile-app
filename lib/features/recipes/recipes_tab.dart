part of 'package:iosapp/main.dart';

extension _ShareDisplayRecipesTab on _ShareDisplayPageState {
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

}
