import 'dart:async';
import 'dart:convert';

import 'package:vertecx/core/session_storage.dart';
import 'package:vertecx/core/session_storage_io.dart'
    if (dart.library.html) 'package:vertecx/core/session_storage_web.dart';

class SessionContext {
  static final SessionStorage _storage = createSessionStorage();
  static const String _accessKey = 'session_access_token';
  static const String _refreshKey = 'session_refresh_token';
  static const String _permissionsKey = 'session_permissions';

  static List<String> _permissions = const <String>[];
  static String? _accessToken;
  static String? _refreshToken;
  static bool _isHydrated = false;
  static Future<void>? _hydrateInFlight;

  static List<String> get permissions => _permissions;
  static set permissions(List<String> value) {
    _permissions = List<String>.from(value);
    unawaited(_persistPermissions());
  }

  static String? get accessToken => _accessToken;
  static set accessToken(String? value) {
    _accessToken = value;
    unawaited(_persistAccessToken());
  }

  static String? get refreshToken => _refreshToken;
  static set refreshToken(String? value) {
    _refreshToken = value;
    unawaited(_persistRefreshToken());
  }

  static Future<void> hydrateFromStorage() async {
    bool hadStorageError = false;
    String? access;
    String? refresh;
    String? rawPermissions;

    try {
      access = await _storage.read(_accessKey);
    } catch (_) {
      hadStorageError = true;
    }

    try {
      refresh = await _storage.read(_refreshKey);
    } catch (_) {
      hadStorageError = true;
    }

    try {
      rawPermissions = await _storage.read(_permissionsKey);
    } catch (_) {
      hadStorageError = true;
    }

    if (hadStorageError) {
      await _clearPersistedSessionSafely();
    }

    _accessToken = (access == null || access.isEmpty) ? null : access;
    _refreshToken = (refresh == null || refresh.isEmpty) ? null : refresh;
    _permissions = _parsePermissions(rawPermissions);
    _isHydrated = true;
  }

  static Future<void> ensureHydrated() async {
    if (_isHydrated) return;
    if (_hydrateInFlight != null) {
      await _hydrateInFlight;
      return;
    }

    final future = hydrateFromStorage();
    _hydrateInFlight = future;
    try {
      await future;
    } finally {
      _hydrateInFlight = null;
    }
  }

  static void setTokens({required String access, required String refresh}) {
    _isHydrated = true;
    _accessToken = access;
    _refreshToken = refresh;
    unawaited(_persistAccessToken());
    unawaited(_persistRefreshToken());
  }

  static void clearAuth() {
    _isHydrated = true;
    _accessToken = null;
    _refreshToken = null;
    unawaited(_safeDelete(_accessKey));
    unawaited(_safeDelete(_refreshKey));
  }

  static void clearAll() {
    _isHydrated = true;
    _permissions = const <String>[];
    clearAuth();
    unawaited(_safeDelete(_permissionsKey));
  }

  static Future<void> _persistAccessToken() async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      await _safeDelete(_accessKey);
      return;
    }
    await _safeWrite(_accessKey, _accessToken!);
  }

  static Future<void> _persistRefreshToken() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      await _safeDelete(_refreshKey);
      return;
    }
    await _safeWrite(_refreshKey, _refreshToken!);
  }

  static Future<void> _persistPermissions() async {
    if (_permissions.isEmpty) {
      await _safeDelete(_permissionsKey);
      return;
    }
    await _safeWrite(_permissionsKey, jsonEncode(_permissions));
  }

  static Future<void> _clearPersistedSessionSafely() async {
    await _safeDelete(_accessKey);
    await _safeDelete(_refreshKey);
    await _safeDelete(_permissionsKey);
  }

  static Future<void> _safeWrite(String key, String value) async {
    try {
      await _storage.write(key, value);
    } catch (_) {}
  }

  static Future<void> _safeDelete(String key) async {
    try {
      await _storage.delete(key);
    } catch (_) {}
  }

  static List<String> _parsePermissions(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const <String>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    return const <String>[];
  }
}
