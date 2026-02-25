import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vertecx/core/session_context.dart';

class ApiHttp {
  static final http.Client _client = http.Client();
  static Future<bool>? _refreshInFlight;

  static Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    return _sendWithRefresh(
      uri: uri,
      headers: headers,
      send: (h) => _client.get(uri, headers: h),
    );
  }

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _sendWithRefresh(
      uri: uri,
      headers: headers,
      send: (h) =>
          _client.post(uri, headers: h, body: body, encoding: encoding),
    );
  }

  static Future<http.Response> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _sendWithRefresh(
      uri: uri,
      headers: headers,
      send: (h) =>
          _client.patch(uri, headers: h, body: body, encoding: encoding),
    );
  }

  static Future<http.Response> _sendWithRefresh({
    required Uri uri,
    required Map<String, String>? headers,
    required Future<http.Response> Function(Map<String, String>) send,
  }) async {
    await SessionContext.ensureHydrated();

    final firstHeaders = _buildHeaders(headers);
    final firstResponse = await send(firstHeaders);

    if (firstResponse.statusCode != 401 || _isRefreshEndpoint(uri)) {
      return firstResponse;
    }

    final refreshed = await _refreshTokens(uri);
    if (!refreshed) {
      return firstResponse;
    }

    final retryHeaders = _buildHeaders(headers, forceAuthorization: true);
    return send(retryHeaders);
  }

  static Map<String, String> _buildHeaders(
    Map<String, String>? headers, {
    bool forceAuthorization = false,
  }) {
    final merged = <String, String>{...?headers};

    final token = SessionContext.accessToken;
    if (token == null || token.isEmpty) {
      return merged;
    }

    final hasAuthorization = merged.keys.any(
      (k) => k.toLowerCase() == 'authorization',
    );

    if (!hasAuthorization || forceAuthorization) {
      merged['Authorization'] = 'Bearer $token';
    }

    return merged;
  }

  static bool _isRefreshEndpoint(Uri uri) {
    return uri.path.endsWith('/auth/refresh');
  }

  static Future<bool> _refreshTokens(Uri failedRequestUri) async {
    final refresh = SessionContext.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      return false;
    }

    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    final future = _runRefresh(failedRequestUri, refresh);
    _refreshInFlight = future;
    final ok = await future;
    _refreshInFlight = null;
    return ok;
  }

  static Future<bool> _runRefresh(Uri failedRequestUri, String refresh) async {
    final refreshUri = failedRequestUri.resolve('/auth/refresh');

    try {
      final response = await _client.post(
        refreshUri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh_token': refresh}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        SessionContext.clearAuth();
        return false;
      }

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        SessionContext.clearAuth();
        return false;
      }

      final accessToken = (body['access_token'] ?? '').toString();
      final refreshToken = (body['refresh_token'] ?? '').toString();

      if (accessToken.isEmpty || refreshToken.isEmpty) {
        SessionContext.clearAuth();
        return false;
      }

      SessionContext.setTokens(access: accessToken, refresh: refreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }
}
