// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'session_storage.dart';

SessionStorage createSessionStorage() => _WebSessionStorage();

class _WebSessionStorage implements SessionStorage {
  @override
  Future<String?> read(String key) async => html.window.localStorage[key];

  @override
  Future<void> write(String key, String value) async {
    html.window.localStorage[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    html.window.localStorage.remove(key);
  }
}
