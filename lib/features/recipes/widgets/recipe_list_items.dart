part of 'package:iosapp/main.dart';

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
