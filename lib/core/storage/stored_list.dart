import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../locale/locale_provider.dart';

/// JSON ro'yxatni telefonda (shared_preferences) saqlovchi umumiy notifier.
/// Mashg'ulot jurnali, vazn tarixi, ovqat jurnali — hammasi shu asosda.
/// TODO(backend): serverga sinxronlash.
abstract class StoredList<T> extends StateNotifier<List<T>> {
  StoredList(this.ref, this._key) : super(const []) {
    final raw = ref.read(sharedPrefsProvider).getString(_key);
    if (raw != null) {
      state = [
        for (final e in jsonDecode(raw) as List)
          decode(e as Map<String, Object?>),
      ];
    }
  }

  final Ref ref;
  final String _key;

  T decode(Map<String, Object?> json);
  Map<String, Object?> encode(T item);

  /// Holatni yangilaydi va telefonga yozadi.
  void save(List<T> items) {
    state = items;
    ref
        .read(sharedPrefsProvider)
        .setString(_key, jsonEncode([for (final e in items) encode(e)]));
  }

  void clear() => save(const []);
}
