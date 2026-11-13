import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static late final SharedPreferences prefs;
  static Future<void>? _initialization;

  /// 初始化SharedPreferences
  static Future<void> init() async {
    final initialization = _initialization ??= _loadPreferences();
    try {
      await initialization;
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  static Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// 保存数据
  static Future<bool> setData<T>(String key, T value) async {
    await init();

    if (value is String) {
      return await prefs.setString(key, value);
    } else if (value is int) {
      return await prefs.setInt(key, value);
    } else if (value is double) {
      return await prefs.setDouble(key, value);
    } else if (value is bool) {
      return await prefs.setBool(key, value);
    } else if (value is List<String>) {
      return await prefs.setStringList(key, value);
    } else {
      return await prefs.setString(key, json.encode(value));
    }
  }

  /// 获取String类型数据
  static String? getString(String key, {String? defaultValue}) {
    return prefs.getString(key) ?? defaultValue;
  }

  /// 获取int类型数据
  static int? getInt(String key, {int? defaultValue}) {
    return prefs.getInt(key) ?? defaultValue;
  }

  /// 获取double类型数据
  static double? getDouble(String key, {double? defaultValue}) {
    return prefs.getDouble(key) ?? defaultValue;
  }

  /// 获取bool类型数据
  static bool? getBool(String key, {bool? defaultValue}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  /// 获取List<String>类型数据
  static List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return prefs.getStringList(key) ?? defaultValue;
  }

  /// 获取JSON对象
  static T? getJson<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final String? jsonString = getString(key);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// 删除指定key的数据
  static Future<bool> remove(String key) async {
    await init();
    return await prefs.remove(key);
  }

  /// 清空所有数据
  static Future<bool> clear() async {
    await init();
    return await prefs.clear();
  }

  /// 获取所有key
  static Set<String>? getKeys() {
    return prefs.getKeys();
  }

  /// 是否包含某个key
  static bool? containsKey(String key) {
    return prefs.containsKey(key);
  }
}
