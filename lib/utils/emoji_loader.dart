import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../models/emoji_model.dart';

import 'package:flutter/foundation.dart';

class EmojiLoader {
  static Future<List<CategoryEmoji>> loadFromAsset(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);

      if (jsonString.isEmpty) {
        return [];
      }

      // 解析 JSON
      final dynamic decodedJson = json.decode(jsonString);
      if (decodedJson is! Map<String, dynamic>) {
        return [];
      }

      final Map<String, dynamic> jsonData = decodedJson;

      // 解析每个分组的表情
      List<CustomEmojiGroup> groups = [];
      jsonData.forEach((group, emojis) {
        if (emojis is List) {
          try {
            groups.add(CustomEmojiGroup.fromJson(group, emojis));
          } catch (e) {
            debugPrint('解析分组 $group 时出错: $e');
          }
        } else {
          debugPrint('警告: 分组 $group 的数据不是列表格式');
        }
      });

      final result = groups.map((group) => group.toCategoryEmoji()).toList();
      debugPrint('表情加载完成，共 ${result.length} 个分组');
      return result;
    } catch (e, stackTrace) {
      debugPrint('加载自定义表情时出错: $e --- $stackTrace');
      return [];
    }
  }

  static List<CategoryEmoji> Function(Locale? locale) createEmojiSetCallback(
    String assetPath,
  ) {
    List<CategoryEmoji>? cachedEmojis;
    bool isLoading = false;

    return (Locale? locale) {
      if (cachedEmojis != null) {
        return cachedEmojis!;
      }

      if (!isLoading) {
        isLoading = true;
        loadFromAsset(assetPath)
            .then((emojis) {
              cachedEmojis = emojis;
              isLoading = false;
              debugPrint('表情异步加载完成，共 ${emojis.length} 个分组');
            })
            .catchError((error) {
              isLoading = false;
              debugPrint('表情异步加载失败: $error');
            });
      }

      return [];
    };
  }
}
