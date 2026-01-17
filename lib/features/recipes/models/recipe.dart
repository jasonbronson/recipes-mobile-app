part of 'package:iosapp/main.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.summary,
    required this.prepTime,
    required this.totalTime,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.raw,
    this.note,
    this.category,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String? imageUrl;
  final String? summary;
  final String? prepTime;
  final String? totalTime;
  final String? servings;
  final List<String> ingredients;
  final List<String> instructions;
  final Map<String, dynamic> raw;
  final String? note;
  final String? category;
  final bool isFavorite;

  bool get hasMeta => prepTime != null || totalTime != null || servings != null;

  List<Uri> get originalUris {
    final Set<String> seen = <String>{};
    final List<Uri> result = <Uri>[];

    void addUri(Uri? uri) {
      if (uri == null || !uri.hasScheme) {
        return;
      }
      final String scheme = uri.scheme.toLowerCase();
      if (scheme != 'http' && scheme != 'https') {
        return;
      }
      // Filter out malformed URLs (missing host or invalid format)
      if (uri.host.isEmpty || uri.host == '') {
        // ignore: avoid_print
        print('iOS: Skipping malformed URL: $uri');
        return;
      }
      final String key = uri.toString();
      if (seen.add(key)) {
        result.add(uri);
      }
    }

    void handle(dynamic candidate) {
      if (candidate == null) {
        return;
      }

      if (candidate is Map<dynamic, dynamic>) {
        final List<dynamic> nestedValues = <dynamic>[
          candidate['url'],
          candidate['link'],
          candidate['href'],
          candidate['source'],
          candidate['@id'],
        ]..removeWhere((dynamic value) => value == null);
        for (final dynamic nested in nestedValues) {
          handle(nested);
        }
        return;
      }

      if (candidate is Iterable<dynamic> && candidate is! String) {
        for (final dynamic item in candidate) {
          handle(item);
        }
        return;
      }

      final String? value = _stringOrNull(candidate);
      if (value == null) {
        return;
      }

      final String normalized = value.trim();
      if (normalized.isEmpty) {
        return;
      }

      // ignore: avoid_print
      print('iOS: Processing URL candidate: "$normalized"');

      final Uri? direct = Uri.tryParse(normalized);
      addUri(direct);

      // Only try to add protocol for very specific cases where we're confident it's a domain
      if (!(normalized.contains('://')) &&
          !normalized.startsWith('/') &&
          !normalized.startsWith('#') &&
          normalized.contains('.') &&
          !normalized.contains(' ')) {
        addUri(Uri.tryParse('https://$normalized'));
      }
    }

    // Prioritize complete URLs from the API
    final List<dynamic> candidates = <dynamic>[
      raw['originalURL'],
      raw['original_url'],
      raw['originalUrl'],
      raw['sourceURL'],
      raw['source_url'],
      raw['canonicalUrl'],
      raw['canonical_url'],
      // Only include these if they look like complete URLs
      raw['source'],
      raw['canonical'],
    ];

    for (final dynamic candidate in candidates) {
      handle(candidate);
    }

    return result;
  }

  String? get originalUrl =>
      originalUris.isEmpty ? null : originalUris.first.toString();

  static List<Recipe> listFromAny(dynamic data) {
    if (data is List<dynamic>) {
      return data
          .map((dynamic item) => Recipe.fromJson(_coerceMap(item)))
          .whereType<Recipe>()
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final List<dynamic>? items = _extractList(data);
      if (items != null) {
        return items
            .map((dynamic item) => Recipe.fromJson(_coerceMap(item)))
            .whereType<Recipe>()
            .toList();
      }
    }

    return <Recipe>[];
  }

  static Map<String, dynamic>? _coerceMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return null;
  }

  static List<dynamic>? _extractList(Map<String, dynamic> data) {
    for (final String key in <String>['recipes', 'data', 'items']) {
      final dynamic value = data[key];
      if (value is List<dynamic>) {
        return value;
      }
    }
    return null;
  }

  factory Recipe.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('Recipe json cannot be null');
    }

    final String title = (json['title'] ?? json['name'] ?? 'Untitled Recipe')
        .toString();
    final String idCandidate =
        (json['id'] ?? json['recipe_id'] ?? json['uuid'] ?? title).toString();
    final Object? imageValue =
        json['image'] ?? json['image_url'] ?? json['thumbnail'];
    final String? imageUrl = imageValue?.toString();
    final String? summary =
        (json['summary'] ?? json['description'] ?? json['details'])?.toString();
    final String? prepTime = _stringFrom(json, <String>[
      'prep_time',
      'prepTime',
      'prep_minutes',
      'prepTimeMinutes',
      'preparation_time',
      'preparationTime',
    ], treatAsDuration: true);
    final String? totalTime = _stringFrom(json, <String>[
      'total_time',
      'totalTime',
      'time',
      'cook_time',
      'cookTime',
      'duration',
    ], treatAsDuration: true);
    final String? servings = _stringFrom(json, <String>[
      'servings',
      'yield',
      'yields',
      'servings_count',
      'servingsCount',
      'portion',
      'portions',
    ]);

    final List<String> ingredients = _stringListFrom(json['ingredients']);
    final List<String> instructions = _stringListFrom(json['instructions']);
    final String? note = _stringOrNull(json['note']);
    final String? category = _stringOrNull(
      json['category'] ?? json['Category'] ?? json['type'],
    );
    final dynamic favoriteValue = json['isFavorite'];
    final bool isFavorite =
        favoriteValue == true ||
        (favoriteValue is String && favoriteValue.toLowerCase() == 'true');

    if (instructions.isEmpty) {
      final String? instructionText = json['instruction']?.toString();
      if (instructionText != null && instructionText.isNotEmpty) {
        instructions.add(instructionText);
      }
    }

    return Recipe(
      id: idCandidate,
      title: title,
      imageUrl: imageUrl,
      summary: summary,
      prepTime: prepTime,
      totalTime: totalTime,
      servings: servings,
      ingredients: ingredients,
      instructions: instructions,
      raw: json,
      note: note,
      category: category,
      isFavorite: isFavorite,
    );
  }

  Recipe copyWith({
    String? title,
    List<String>? instructions,
    List<String>? ingredients,
    String? note,
    String? category,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id,
      title: title ?? this.title,
      imageUrl: imageUrl,
      summary: summary,
      prepTime: prepTime,
      totalTime: totalTime,
      servings: servings,
      ingredients: ingredients != null
          ? List<String>.from(ingredients)
          : List<String>.from(this.ingredients),
      instructions: instructions != null
          ? List<String>.from(instructions)
          : List<String>.from(this.instructions),
      raw: raw,
      note: note ?? this.note,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static List<String> _stringListFrom(dynamic value) {
    if (value is List<dynamic>) {
      return value.map((dynamic item) => item.toString()).toList();
    }

    if (value is String && value.isNotEmpty) {
      return value
          .split(RegExp(r'\r?\n'))
          .map((String line) => line.trim())
          .toList();
    }

    return <String>[];
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    final String trimmed = value.toString().trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _stringFrom(
    Map<String, dynamic> json,
    List<String> keys, {
    bool treatAsDuration = false,
  }) {
    for (final String key in keys) {
      final dynamic value = _lookupValue(json, key);
      final String? normalized = _normalizeValue(
        value,
        treatAsDuration: treatAsDuration,
      );
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return null;
  }

  static dynamic _lookupValue(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) {
      return json[key];
    }

    for (final String containerKey in <String>['meta', 'details', 'info']) {
      final dynamic container = json[containerKey];
      if (container is Map<String, dynamic> && container.containsKey(key)) {
        return container[key];
      }
    }

    return null;
  }

  static String? _normalizeValue(
    dynamic value, {
    bool treatAsDuration = false,
  }) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      final String numericString = value == value.roundToDouble()
          ? value.toInt().toString()
          : '$value';
      return treatAsDuration ? '$numericString min' : numericString;
    }

    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }

      if (treatAsDuration && RegExp(r'^\d+(?:\.\d+)?$').hasMatch(trimmed)) {
        // Append minutes if the value looks purely numeric.
        return '$trimmed min';
      }

      return trimmed;
    }

    return value.toString();
  }

  // Note: slug-related helpers and fields removed. API calls use `id`.
}
