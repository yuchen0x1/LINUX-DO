import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' hide Category;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji
    show Category;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:linux_do/utils/storage_manager.dart';

class EmojiManager {
  static final EmojiManager _instance = EmojiManager._internal();
  factory EmojiManager() => _instance;
  EmojiManager._internal();

  final Map<String, CustomEmoji> _emojiMap = {};
  List<CategoryEmoji> _categoryEmojis = [];
  bool _isInitialized = false;

  Future<void> init(String assetPath) async {
    if (_isInitialized) return;

    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      if (jsonString.isEmpty) return;

      final dynamic decodedJson = json.decode(jsonString);
      if (decodedJson is! Map<String, dynamic>) return;

      final Map<String, dynamic> jsonData = decodedJson;

      // 解析分组和表情
      List<CustomEmojiGroup> groups = [];
      jsonData.forEach((group, emojis) {
        if (emojis is List) {
          groups.add(CustomEmojiGroup.fromJson(group, emojis));
        }
      });

      // 填充表情映射和分类数据
      _emojiMap.clear();
      _categoryEmojis = groups.map((group) {
        for (var emoji in group.emojis) {
          _emojiMap[emoji.name] = emoji;
        }
        return group.toCategoryEmoji();
      }).toList();

      _isInitialized = true;
      debugPrint(
          'EmojiManager 初始化完成，${_categoryEmojis.length} 个分组，${_emojiMap.length} 个表情');
    } catch (e, stackTrace) {
      debugPrint('EmojiManager 初始化失败: $e --- $stackTrace');
    }
  }

  // 获取单个表情
  CustomEmoji? getEmoji(String name) => _emojiMap[name];

  // 获取用于 EmojiPicker 的分类数据
  List<CategoryEmoji> getCategoryEmojis() => _categoryEmojis;

  // 预加载所有表情图片
  void precacheImages(BuildContext context) {
    for (var emoji in _emojiMap.values) {
      precacheImage(AssetImage(emoji.url), context);
    }
    debugPrint('所有表情图片预加载完成');
  }
}

// 表情数据模型
class CustomEmoji {
  final String name;
  final String url;
  final String group;

  CustomEmoji({
    required this.name,
    required this.url,
    required this.group,
  });

  factory CustomEmoji.fromJson(Map<String, dynamic> json) {
    String url = json['url'] as String? ?? '';
    if (!url.startsWith('asset://')) {
      url = 'assets/emojis/${json['name']}.png';
    } else {
      url = url.replaceFirst('asset://', '');
    }

    return CustomEmoji(
      name: json['name'] as String? ?? '',
      url: url,
      group: json['group'] as String? ?? '',
    );
  }

  Emoji toEmoji() => Emoji('🙂', name, imageUrl: url);
}

// 表情分组
class CustomEmojiGroup {
  final String group;
  final List<CustomEmoji> emojis;

  CustomEmojiGroup({required this.group, required this.emojis});

  factory CustomEmojiGroup.fromJson(String group, List<dynamic> json) {
    return CustomEmojiGroup(
      group: group,
      emojis: json
          .whereType<Map<String, dynamic>>()
          .map((e) => CustomEmoji.fromJson(e))
          .toList(),
    );
  }

  CategoryEmoji toCategoryEmoji() {
    return CategoryEmoji(
      getCategoryFromGroup(group),
      emojis.map((e) => e.toEmoji()).toList(),
    );
  }

  static emoji.Category getCategoryFromGroup(String group) {
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

List<InlineSpan> parseTextWithEmojis(
    String text, double? fontSize, BuildContext context) {
  final bool isAnimated =
      StorageManager.getBool('animated_emoji_enabled') ?? true;
  final RegExp emojiRegex = RegExp(r':([a-zA-Z0-9_]+):');
  final List<InlineSpan> spans = [];
  int lastIndex = 0;

  for (final match in emojiRegex.allMatches(text)) {
    if (match.start > lastIndex) {
      spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
    }

    final shortcode = match.group(1)!;
    final emoji = EmojiManager().getEmoji(shortcode);
    if (emoji != null) {
      if (!isAnimated && emoji.url.toLowerCase().endsWith('.gif')) {
        spans.add(TextSpan(text: '[$shortcode]'));
      } else {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Image.asset(
                emoji.url,
                width: fontSize,
                height: fontSize,
                errorBuilder: (context, error, stackTrace) =>
                    Text(':$shortcode:'),
              ),
            ),
          ),
        );
      }
    } else {
      spans.add(TextSpan(text: match.group(0)));
    }

    lastIndex = match.end;
  }

  if (lastIndex < text.length) {
    spans.add(TextSpan(text: text.substring(lastIndex)));
  }

  return spans;
}
