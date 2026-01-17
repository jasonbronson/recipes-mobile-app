part of 'package:iosapp/main.dart';

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
                        // ignore: avoid_print
                        print('iOS: Trying to launch $uri with mode: $mode');
                        try {
                          final bool launched = await launchUrl(
                            uri,
                            mode: mode,
                          );
                          if (launched) {
                            // ignore: avoid_print
                            print(
                              'iOS: Successfully launched with mode: $mode',
                            );
                            return;
                          }
                        } catch (modeError) {
                          // ignore: avoid_print
                          print('iOS: Mode $mode failed: $modeError');
                        }
                      }
                    } catch (e) {
                      // ignore: avoid_print
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
                          // ignore: deprecated_member_use
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
