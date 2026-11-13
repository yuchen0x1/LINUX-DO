import 'package:flutter/cupertino.dart';

import 'dart:core';

const badgeNames = [
  "龙行龘龘",
  "文化宣导员",
  "第一次通过电子邮件回复",
  "回馈",
  "解决方案机构",
  "幸运佬",
  "全年不落",
  "大预言家",
  "一元复始",
  "蛇来运转",
  "当月最佳新用户",
  "已授权",
  "铜笔杆",
  "精彩的话题",
  "周年纪念日",
  "首次举报",
  "圆圆满满",
  "第一个表情符号",
  "很好的话题",
  "自传作者",
  "拥护者",
  "善解人意",
  "首个 Onebox",
  "不错的分享",
  "首次提及",
  "谢谢",
  "爱好者",
  "Wiki 编辑",
  "已认证",
  "浴火重生",
  "首次分享",
  "指导顾问",
  "受人敬仰",
  "首次链接",
  "很棒的分享",
  "海纳百川",
  "精彩的回复",
  "精彩的分享",
  "种子用户",
  "无所不知",
  "银笔杆",
  "金笔杆",
  "领导者",
  "狂热",
  "出于爱",
  "著名链接",
  "活动家",
  "更多的爱",
  "火热链接",
  "热门链接",
  "受人尊敬",
  "受到赞赏",
  "读者",
  "活跃用户",
  "已解决！",
  "百尺竿头",
  "首次回应",
  "成员",
  "推广者",
  "编辑者",
  "首次引用",
  "很棒的回复",
  "不错的话题",
  "欢迎",
  "第一个赞",
  "阅读准则",
  "不错的回复",
  "基本用户",
];

class BadgeIconHelper {
  static final Map<String, IconData> _iconCache = {};
  static final Map<String, Color> _colorCache = {};

  static IconData getIcon(String badgeName) {
    if (_iconCache.containsKey(badgeName)) {
      return _iconCache[badgeName]!;
    }

    final icon = _getIconForBadge(badgeName);
    _iconCache[badgeName] = icon;
    return icon;
  }

  static Color getColor(String badgeName) {
    if (_colorCache.containsKey(badgeName)) {
      return _colorCache[badgeName]!;
    }

    final color = _generateColorFromName(badgeName);
    _colorCache[badgeName] = color;
    return color;
  }

  static IconData _getIconForBadge(String badgeName) {
    // 根据徽章名称返回对应的图标
    switch (badgeName) {
      case "龙行龘龘":
        return CupertinoIcons.flame;
      case "文化宣导员":
        return CupertinoIcons.book;
      case "回馈":
        return CupertinoIcons.hand_thumbsup;
      case "解决方案机构":
        return CupertinoIcons.lightbulb;
      case "幸运佬":
        return CupertinoIcons.gift;
      case "全年不落":
        return CupertinoIcons.calendar_badge_plus;
      case "大预言家":
        return CupertinoIcons.eye;
      case "一元复始":
        return CupertinoIcons.restart;
      case "当月最佳新用户":
        return CupertinoIcons.person_crop_circle_badge_checkmark;
      case "已授权":
        return CupertinoIcons.checkmark_shield;
      case "铜笔杆":
      case "银笔杆":
      case "金笔杆":
        return CupertinoIcons.pencil;
      case "精彩的话题":
      case "很好的话题":
      case "不错的话题":
        return CupertinoIcons.chat_bubble_2;
      case "周年纪念日":
        return CupertinoIcons.gift_alt;
      case "首次举报":
        return CupertinoIcons.flag;
      case "圆圆满满":
        return CupertinoIcons.circle_filled;
      case "第一个表情符号":
        return CupertinoIcons.smiley;
      case "自传作者":
        return CupertinoIcons.person_crop_circle;
      case "拥护者":
        return CupertinoIcons.heart;
      case "善解人意":
        return CupertinoIcons.hand_raised;
      case "谢谢":
        return CupertinoIcons.heart_circle;
      case "爱好者":
        return CupertinoIcons.star;
      case "Wiki 编辑":
        return CupertinoIcons.doc_text_search;
      case "已认证":
        return CupertinoIcons.checkmark_seal;
      case "浴火重生":
        return CupertinoIcons.flame;
      case "指导顾问":
        return CupertinoIcons.person_2;
      case "受人敬仰":
        return CupertinoIcons.star_circle;
      case "海纳百川":
        return CupertinoIcons.drop;
      case "精彩的回复":
      case "很棒的回复":
      case "不错的回复":
        return CupertinoIcons.chat_bubble_text;
      case "无所不知":
        return CupertinoIcons.lightbulb_fill;
      case "领导者":
        return CupertinoIcons.person_crop_circle_badge_exclam;
      case "狂热":
        return CupertinoIcons.bolt;
      case "出于爱":
      case "更多的爱":
        return CupertinoIcons.heart_fill;
      case "活动家":
        return CupertinoIcons.person_3;
      case "受人尊敬":
      case "受到赞赏":
        return CupertinoIcons.hand_thumbsup_fill;
      case "读者":
        return CupertinoIcons.book_fill;
      case "活跃用户":
        return CupertinoIcons.person_crop_circle_fill;
      case "已解决！":
        return CupertinoIcons.checkmark_circle;
      case "百尺竿头":
        return CupertinoIcons.arrow_up_circle;
      case "推广者":
        return CupertinoIcons.arrow_right_circle;
      case "编辑者":
        return CupertinoIcons.pencil_circle;
      case "欢迎":
        return CupertinoIcons.hand_raised_fill;
      case "第一个赞":
        return CupertinoIcons.hand_thumbsup;
      case "阅读准则":
        return CupertinoIcons.doc_text;
      case "基本用户":
        return CupertinoIcons.person;
      default:
        return CupertinoIcons.star; // 默认图标
    }
  }

  static Color _generateColorFromName(String name) {
    final int hash = name.hashCode;
    const List<Color> baseColors = [
      Color(0xFF1abc9c),
      Color(0xFF2ecc71),
      Color(0xFF27ae60),
      Color(0xFF3498db),
      Color(0xFF2980b9),
      Color(0xFF00bcd4),
      Color(0xFF9b59b6),
      Color(0xFF8e44ad),
      Color(0xFFe040fb),
      Color(0xFFf1c40f),
      Color(0xFFffd700),
      Color(0xFFffeb3b),
      Color(0xFFe67e22),
      Color(0xFFff9800),
      Color(0xFFff5722),
      Color(0xFFe74c3c),
      Color(0xFFf44336),
      Color(0xFFff4081),
      Color(0xFF00acc1),
      Color(0xFF26c6da),
      Color(0xFF4dd0e1),
      Color(0xFF4caf50),
      Color(0xFF8bc34a),
      Color(0xFF7cb342),
      Color(0xFF009688),
      Color(0xFF00bfa5),
      Color(0xFF64ffda),
    ];

    // 使用哈希值选择一个基础颜色
    final baseColor = baseColors[hash.abs() % baseColors.length];

    // 使用哈希值微调色相，以获得更多变化
    final hslColor = HSLColor.fromColor(baseColor);
    final adjustedHue = (hslColor.hue + (hash % 30)) % 360;

    return hslColor.withHue(adjustedHue).toColor();
  }
}
