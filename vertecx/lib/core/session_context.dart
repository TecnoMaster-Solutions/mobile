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
  static const String _userIdKey = 'session_user_id';
  static const String _roleNameKey = 'session_role_name';
  static const String _customerIdKey = 'session_customer_id';
  static const String _technicianIdKey = 'session_technician_id';

  static List<String> _permissions = const <String>[];
  static String? _accessToken;
  static String? _refreshToken;
  static int? _userId;
  static String? _roleName;
  static int? _customerId;
  static int? _technicianId;
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

  static int? get currentUserId {
    final payload = _decodeAccessPayload();
    if (payload == null) return null;
    return _toInt(payload['userid']) ?? _toInt(payload['userId']) ?? _toInt(payload['sub']);
  }

  static String? get currentRoleName {
    final payload = _decodeAccessPayload();
    if (payload == null) return null;
    final role =
        payload['rolename'] ?? payload['roleName'] ?? payload['role'];
    if (role is! String) return null;
    final normalized = role.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static int? get userId => _userId;
  static set userId(int? value) {
    _userId = value;
    unawaited(_persistInt(_userIdKey, value));
  }

  static String? get roleName => _roleName;
  static set roleName(String? value) {
    _roleName = value?.trim().isEmpty ?? true ? null : value?.trim();
    unawaited(_persistString(_roleNameKey, _roleName));
  }

  static int? get customerId => _customerId;
  static set customerId(int? value) {
    _customerId = value;
    unawaited(_persistInt(_customerIdKey, value));
  }

  static int? get technicianId => _technicianId;
  static set technicianId(int? value) {
    _technicianId = value;
    unawaited(_persistInt(_technicianIdKey, value));
  }

  static String get normalizedRoleName {
    final value = (_roleName ?? '').toLowerCase().trim();
    return value
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  static bool get isClientRole {
    final role = normalizedRoleName;
    return role == 'cliente' || role == 'client' || role == 'customer';
  }

  static bool get isTechnicianRole {
    final role = normalizedRoleName;
    return role == 'tecnico' || role == 'technician' || role == 'technical';
  }

  static Future<void> hydrateFromStorage() async {
    bool hadStorageError = false;
    String? access;
    String? refresh;
    String? rawPermissions;
    String? rawUserId;
    String? rawRoleName;
    String? rawCustomerId;
    String? rawTechnicianId;

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

    try {
      rawUserId = await _storage.read(_userIdKey);
    } catch (_) {
      hadStorageError = true;
    }

    try {
      rawRoleName = await _storage.read(_roleNameKey);
    } catch (_) {
      hadStorageError = true;
    }

    try {
      rawCustomerId = await _storage.read(_customerIdKey);
    } catch (_) {
      hadStorageError = true;
    }

    try {
      rawTechnicianId = await _storage.read(_technicianIdKey);
    } catch (_) {
      hadStorageError = true;
    }

    if (hadStorageError) {
      await _clearPersistedSessionSafely();
    }

    _accessToken = (access == null || access.isEmpty) ? null : access;
    _refreshToken = (refresh == null || refresh.isEmpty) ? null : refresh;
    _permissions = _parsePermissions(rawPermissions);
    _userId = _parseInt(rawUserId);
    _roleName =
        (rawRoleName == null || rawRoleName.trim().isEmpty)
            ? null
            : rawRoleName.trim();
    _customerId = _parseInt(rawCustomerId);
    _technicianId = _parseInt(rawTechnicianId);
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

  static void setUser({
    required int userId,
    required String roleName,
    int? customerId,
    int? technicianId,
  }) {
    _isHydrated = true;
    _userId = userId;
    _roleName = roleName.trim().isEmpty ? null : roleName.trim();
    _customerId = customerId;
    _technicianId = technicianId;
    unawaited(_persistInt(_userIdKey, _userId));
    unawaited(_persistString(_roleNameKey, _roleName));
    unawaited(_persistInt(_customerIdKey, _customerId));
    unawaited(_persistInt(_technicianIdKey, _technicianId));
  }

  static void clearAuth() {
    _isHydrated = true;
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _roleName = null;
    _customerId = null;
    _technicianId = null;
    unawaited(_safeDelete(_accessKey));
    unawaited(_safeDelete(_refreshKey));
    unawaited(_safeDelete(_userIdKey));
    unawaited(_safeDelete(_roleNameKey));
    unawaited(_safeDelete(_customerIdKey));
    unawaited(_safeDelete(_technicianIdKey));
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
    await _safeDelete(_userIdKey);
    await _safeDelete(_roleNameKey);
    await _safeDelete(_customerIdKey);
    await _safeDelete(_technicianIdKey);
  }

  static Future<void> _persistString(String key, String? value) async {
    if (value == null || value.isEmpty) {
      await _safeDelete(key);
      return;
    }
    await _safeWrite(key, value);
  }

  static Future<void> _persistInt(String key, int? value) async {
    if (value == null) {
      await _safeDelete(key);
      return;
    }
    await _safeWrite(key, value.toString());
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

  static Map<String, dynamic>? _decodeAccessPayload() {
    final token = _accessToken;
    if (token == null || token.isEmpty) return null;

    try {
      if (token.trim().startsWith('{')) {
        final parsed = jsonDecode(token);
        return parsed is Map<String, dynamic> ? parsed : null;
      }

      final parts = token.split('.');
      if (parts.length != 3) return null;

      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      return payload is Map<String, dynamic> ? payload : null;
    } catch (_) {
      return null;
    }
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static int? _parseInt(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return int.tryParse(raw.trim());
  }
}
