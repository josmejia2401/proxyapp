import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();

  CacheService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ───────────────────────────────
  // GENERAL STORAGE HELPERS
  // ───────────────────────────────

  Future<void> writeString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? readString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> writeJson(String key, Map<String, dynamic> data) async {
    await _prefs?.setString(key, jsonEncode(data));
  }

  Map<String, dynamic>? readJson(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  Future<void> writeList(String key, List<String> items) async {
    await _prefs?.setStringList(key, items);
  }

  List<String> readList(String key) {
    return _prefs?.getStringList(key) ?? [];
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }

}
