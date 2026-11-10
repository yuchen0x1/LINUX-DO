import 'package:flutter/material.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/storage_manager.dart';

class AppColors {
  /// L站 主色调
  static const Color primary = Color(0xFF2196F3);

  /// L站 亮色
  static const Color primaryLight = Color(0xFF64B5F6);

  /// 次要颜色
  static const Color secondary = Color(0xFFD7EFFD);

  /// 次要颜色 2
  static const Color secondary2 = Color.fromARGB(255, 101, 180, 245);

  /// 背景色
  static const Color background = Color(0xFFF5F5F5);

  /// 主色调不同透明度
  static const Color primary80 = Color(0xCC1976D2); // 80% 透明度
  static const Color primary60 = Color(0x991976D2); // 60% 透明度
  static const Color primary40 = Color(0x661976D2); // 40% 透明度
  static const Color primary20 = Color(0x331976D2); // 20% 透明度

  /// logo的色调
  static const Color logoColor1 = Color(0xFF1C1C1E);
  static const Color logoColor2 = Color(0xFFF0F0F0);
  static const Color logoColor3 = Color(0xFFF3B33F);

  /// 文字颜色
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);

  /// 分割线颜色
  static const Color divider = Color(0xFFEEEEEE);

  /// 边框颜色
  static const Color border = Color(0xFFDDDDDD);

  /// 卡片阴影颜色
  static const Color shadow = Color(0x1A000000);

  /// 成功状态颜色
  static const Color success = Color(0xFF4CAF50);

  /// 警告状态颜色
  static const Color warning = Color(0xFFFFA726);

  /// 错误状态颜色
  static const Color error = Color(0xFFE57373);

  /// 禁用状态颜色
  static const Color disabled = Color(0xFFBFBFBF);

  /// 白色
  static const Color white = Colors.white;

  /// 黑色
  static const Color black = Colors.black;

  /// 透明色
  static const Color transparent = Colors.transparent;

  /// l-1
  static const Color l1 = Color(0xFFEDB441);

  /// l-2
  static const Color l2 = Color(0xFFE14434);

  /// l-3
  static const Color l3 = Color(0xFFD76F3C);

  /// 创建 MaterialColor
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  /// 亮色主题颜色
  static final light = _Colors(
    background: const Color(0xFFF5F5F5),
    surface: Colors.white,
    card: Colors.white,
    divider: Colors.grey.shade200,
    text: Colors.black87,
    textSecondary: Colors.black54,
    textHint: Colors.black38,
    icon: Colors.black87,
    iconSecondary: Colors.black54,
    shadow: Colors.black.withValues(alpha: .1),
    inputFillColor: textHint,
  );

  /// 深色主题颜色
  static final dark = _Colors(
    background: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
    card: const Color(0xFF242424),
    divider: Colors.white10,
    text: Colors.white,
    textSecondary: Colors.white70,
    textHint: Colors.white38,
    icon: Colors.white,
    iconSecondary: Colors.white70,
    shadow: Colors.white.withValues(alpha: .1),
    inputFillColor: textHint,
  );

  static Color? getStoredColor() {
    try {
      final colorValue = StorageManager.getInt(AppConst.identifier.themeColor);
      if (colorValue == null) return null;

      return Color(colorValue | 0xFF000000);
    } catch (e, s) {
      l.e('解析存储颜色失败: $e, $s');
      return null;
    }
  }
}

class _Colors {
  final Color background; // 背景色
  final Color surface; // 表面色
  final Color card; // 卡片色
  final Color divider; // 分割线颜色
  final Color text; // 主文本色
  final Color textSecondary; // 次要文本色
  final Color textHint; // 提示文本色
  final Color icon; // 图标色
  final Color iconSecondary; // 次要图标色
  final Color shadow; // 阴影色
  final Color inputFillColor; // 输入框填充色

  const _Colors({
    required this.background,
    required this.surface,
    required this.card,
    required this.divider,
    required this.text,
    required this.textSecondary,
    required this.textHint,
    required this.icon,
    required this.iconSecondary,
    required this.shadow,
    required this.inputFillColor,
  });
}
