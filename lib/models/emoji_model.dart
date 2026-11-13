import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' hide Category;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'
    as emoji
    show Category;
import 'package:flutter/foundation.dart';

class CustomEmojiData {
  final String name;
  final bool tonable;
  final String url;
  final String group;
  final List<String> searchAliases;

  CustomEmojiData({
    required this.name,
    this.tonable = false,
    required this.url,
    required this.group,
    List<String>? searchAliases,
  }) : searchAliases = searchAliases ?? [];

  factory CustomEmojiData.fromJson(Map<String, dynamic> json) {
    String url = json['url'] as String? ?? '';
    // 使用本地资源路径
    if (url.startsWith('/')) {
      url = 'asset://assets/emojis${url.replaceAll('/images/emoji/apple', '')}';
    }

    return CustomEmojiData(
      name: json['name'] as String? ?? '',
      tonable: json['tonable'] as bool? ?? false,
      url: url,
      group: json['group'] as String? ?? '',
      searchAliases:
          (json['search_aliases'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tonable': tonable,
      'url': url,
      'group': group,
      'search_aliases': searchAliases,
    };
  }

  // 转换为 Emoji 对象
  Emoji toEmoji() {
    return Emoji(
      '🙂', // 默认 fallback 表情
      name,
      hasSkinTone: tonable,
      imageUrl: url,
    );
  }
}

class CustomEmojiGroup {
  final String group;
  final List<CustomEmojiData> emojis;

  CustomEmojiGroup({required this.group, required this.emojis});

  factory CustomEmojiGroup.fromJson(String group, List<dynamic> json) {
    try {
      return CustomEmojiGroup(
        group: group,
        emojis: json.map((e) {
          if (e is! Map<String, dynamic>) {
            return CustomEmojiData(name: 'invalid', url: '', group: group);
          }
          return CustomEmojiData.fromJson(e);
        }).toList(),
      );
    } catch (e) {
      debugPrint('解析分组 $group 时出错: $e');
      return CustomEmojiGroup(group: group, emojis: []);
    }
  }

  // 转换为 CategoryEmoji 对象
  CategoryEmoji toCategoryEmoji() {
    return CategoryEmoji(
      _getCategoryFromGroup(group),
      emojis.map((e) => e.toEmoji()).toList(),
    );
  }

  // 将 group 字符串转换为 Category 枚举
  static emoji.Category _getCategoryFromGroup(String group) {
    switch (group.toLowerCase()) {
      case 'smileys_&_emotion':
        return emoji.Category.CUSTOM_SMILEYS;
      case 'people_&_body':
        return emoji.Category.CUSTOM_PEOPLE;
      case 'animals_&_nature':
        return emoji.Category.CUSTOM_ANIMALS;
      case 'food_&_drink':
        return emoji.Category.CUSTOM_FOOD;
      case 'travel_&_places':
        return emoji.Category.CUSTOM_TRAVEL;
      case 'activities':
        return emoji.Category.CUSTOM_ACTIVITIES;
      case 'objects':
        return emoji.Category.CUSTOM_OBJECTS;
      case 'symbols':
        return emoji.Category.CUSTOM_SYMBOLS;
      case 'flags':
        return emoji.Category.FLAGS;
      case 'b站':
      case '飞书':
      case '贴吧':
      case '小红书':
        return emoji.Category.SMILEYS;
      default:
        return emoji.Category.RECENT;
    }
  }
}
