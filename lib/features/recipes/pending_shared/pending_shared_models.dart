part of 'package:iosapp/main.dart';

enum _PendingRecipeStatus { queued, saving, awaitingImport }

class _PendingRecipeEntry {
  const _PendingRecipeEntry({
    required this.id,
    required this.url,
    this.status = _PendingRecipeStatus.queued,
  });

  final String id;
  final String url;
  final _PendingRecipeStatus status;

  _PendingRecipeEntry copyWith({
    String? id,
    String? url,
    _PendingRecipeStatus? status,
  }) {
    return _PendingRecipeEntry(
      id: id ?? this.id,
      url: url ?? this.url,
      status: status ?? this.status,
    );
  }
}
