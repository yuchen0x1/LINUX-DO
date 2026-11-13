import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linux_do/models/badge_detail.dart';

import '../models/category.dart';
import 'log.dart';

class Tag {
  static final Map<String, TagColor> _cache = {};

  // 预定义的颜色列表 主要tag太多了
  static const List<Color> _baseColors = [
    Color(0xFF1976D2),
    Color(0xFF388E3C),
    Color(0xFFF57C00),
    Color(0xFF7B1FA2),
    Color(0xFFC2185B),
    Color(0xFF0097A7),
    Color(0xFF00796B),
    Color(0xFF3F51B5),
    Color(0xFF689F38),
    Color(0xFFE64A19),
  ];

  // 获取标签颜色
  static TagColor getTagColors(String tag) {
    if (_cache.containsKey(tag)) {
      return _cache[tag]!;
    }

    final int hashCode = tag.hashCode.abs();
    final int colorIndex = hashCode % _baseColors.length;
    final baseColor = _baseColors[colorIndex];

    // 创建新的标签颜色
    final tagColor = TagColor(
      textColor: baseColor,
      backgroundColor: baseColor.withValues(alpha: .1),
    );

    // 缓存结果
    _cache[tag] = tagColor;

    return tagColor;
  }

  // 从 JSON 文件加载所有标签并初始化颜色
  static Future<void> init() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/json/tags.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> tags = jsonData['tags'];

      for (var tag in tags) {
        final String tagId = tag['id'];
        getTagColors(tagId); // 生成并缓存颜色
      }
    } catch (e) {
      debugPrint('Error loading tags: $e');
    }
  }

  // 清除缓存
  static void clearCache() {
    _cache.clear();
  }
}

class TagColor {
  final Color textColor;
  final Color backgroundColor;

  const TagColor({required this.textColor, required this.backgroundColor});
}

class CategoryManager {
  static final CategoryManager _instance = CategoryManager._internal();
  factory CategoryManager() => _instance;
  CategoryManager._internal();

  final Map<int, Category> _categories = <int, Category>{};

  Future<void> initialize() async {
    if (_categories.isNotEmpty) {
      l.d('Categories already loaded: ${_categories.length} categories');
      return;
    }
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/json/category.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      for (var item in jsonList) {
        final category = Category(
          id: item['id'],
          name: item['name'],
          englishName: item['english_name'],
          logo: CategoryLogo.fromJson(item['uploaded_logo']),
          logoDark: CategoryLogoDark.fromJson(item['uploaded_logo_dark']),
          slug: item['slug'],
          color: item['color'],
          textColor: item['textColor'],
        );
        _categories[category.id] = category;
      }
    } catch (e, stack) {
      l.e('Error loading categories: $e\n$stack');
    }
  }

  String getCategoryName(int? categoryId) {
    if (categoryId == null) return '';
    return _categories[categoryId]?.name ?? '';
  }

  Category? getCategory(int? categoryId) {
    if (categoryId == null) return null;
    return _categories[categoryId];
  }
}

class BadgeManager {
  static final BadgeManager _instance = BadgeManager._internal();
  factory BadgeManager() => _instance;
  BadgeManager._internal();

  final Map<int, BadgeDetail> _badges = <int, BadgeDetail>{};

  Future<void> initialize() async {
    if (_badges.isNotEmpty) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/json/badge.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      for (var item in jsonList) {
        final badge = BadgeDetail(
          id: item['id'],
          name: item['name'],
          description: item['description'],
          grantCount: item['grant_count'],
          allowTitle: item['allow_title'],
          multipleGrant: item['multiple_grant'],
          listable: item['listable'],
          enabled: item['enabled'],
          badgeGroupingId: item['badge_grouping_id'],
          system: item['system'],
          slug: item['slug'],
          hasBadge: item['has_badge'],
          manuallyGrantable: item['manually_grantable'],
          showInPostHeader: item['show_in_post_header'],
          badgeTypeId: item['badge_type_id'],
        );
        _badges[badge.id] = badge;
      }
    } catch (e, stack) {
      l.e('Error loading badges: $e\n$stack');
    }
  }

  BadgeDetail? getBadge(int? badgeId) {
    if (badgeId == null) return null;
    return _badges[badgeId];
  }
}
