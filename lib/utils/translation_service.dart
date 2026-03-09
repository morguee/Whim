import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:matrix/matrix_api_lite/utils/logs.dart';

import 'package:fluffychat/config/setting_keys.dart';

class TranslatedMessage {
  final String translatedText;
  final String sourceLang;

  const TranslatedMessage({
    required this.translatedText,
    required this.sourceLang,
  });
}

class TranslationService extends ChangeNotifier {
  static final TranslationService instance = TranslationService._();

  TranslationService._();

  // eventId -> TranslatedMessage
  final Map<String, TranslatedMessage> _cache = {};

  // Event IDs that have been checked (fetched from server, even if no translation)
  final Set<String> _checkedEventIds = {};

  // Track in-flight fetches to avoid duplicate requests
  final Set<String> _pendingEventIds = {};

  // Queue for batching individual translation requests (e.g. from room list)
  final Map<String, String> _queue = {}; // eventId -> roomId
  Timer? _queueTimer;

  Client? _matrixClient;

  void init(Client client) {
    _matrixClient = client;
  }

  String get _targetLang => AppSettings.translationLanguage.value;

  String get _baseUrl {
    final homeserver = _matrixClient?.homeserver;
    if (homeserver == null) return '';
    return '${homeserver.scheme}://${homeserver.host}/_whim';
  }

  String get _userId => _matrixClient?.userID ?? '';

  bool get isEnabled => _targetLang.isNotEmpty;

  TranslatedMessage? getTranslation(String eventId) {
    return _cache[eventId];
  }

  /// Whether this event has been checked with the server (even if no translation exists)
  bool hasChecked(String eventId) =>
      _checkedEventIds.contains(eventId) || _cache.containsKey(eventId);

  void clearCache() {
    _cache.clear();
    _checkedEventIds.clear();
    notifyListeners();
  }

  /// Queue a single event for translation. Batched and sent after a short delay.
  /// Use this from room list items to avoid one request per room.
  void queueTranslation(String eventId, {String roomId = ''}) {
    if (!isEnabled) return;
    if (_cache.containsKey(eventId) || _pendingEventIds.contains(eventId)) return;
    _queue[eventId] = roomId;
    _queueTimer?.cancel();
    _queueTimer = Timer(const Duration(milliseconds: 300), _flushQueue);
  }

  Future<void> _flushQueue() async {
    if (_queue.isEmpty) return;
    final batch = Map<String, String>.of(_queue);
    _queue.clear();
    await fetchTranslations(batch.keys.toList());
  }

  Future<void> fetchTranslations(List<String> eventIds, {String roomId = ''}) async {
    if (!isEnabled || eventIds.isEmpty) return;

    // Filter out already cached and in-flight
    final toFetch =
        eventIds.where((id) => !_cache.containsKey(id) && !_pendingEventIds.contains(id)).toList();
    if (toFetch.isEmpty) return;

    _pendingEventIds.addAll(toFetch);

    try {
      final url = Uri.parse('$_baseUrl/translations/batch');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'event_ids': toFetch,
          'target_lang': _targetLang,
          'user_id': _userId,
          'room_id': roomId,
        }),
      );

      if (response.statusCode != 200) return;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final translations = data['translations'] as Map<String, dynamic>?;
      if (translations == null) return;

      var hasNew = false;
      for (final entry in translations.entries) {
        _checkedEventIds.add(entry.key);
        if (entry.value != null) {
          final t = entry.value as Map<String, dynamic>;
          _cache[entry.key] = TranslatedMessage(
            translatedText: t['translated_text'] as String,
            sourceLang: t['source_lang'] as String,
          );
          hasNew = true;
        }
      }

      // Always notify so placeholders update (even for null results)
      notifyListeners();
    } catch (e) {
      Logs().w('Translation fetch error', e);
    } finally {
      _pendingEventIds.removeAll(toFetch);
    }
  }
}
