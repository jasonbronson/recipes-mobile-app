part of 'package:iosapp/main.dart';

extension _ShareDisplayFavoritesTab on _ShareDisplayPageState {
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

}
