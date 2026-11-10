import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrustLevelHelper {
  /// 获取 Linux.do 等级称号
  static String getTitle(int level) {
    switch (level) {
      case 0:
        return '萌新 · TL0';
      case 1:
        return '幼苗 · TL1';
      case 2:
        return '木友 · TL2';
      case 3:
        return '佬友 · TL3';
      case 4:
        return '元老 · TL4';
      default:
        return '社区成员';
    }
  }

  /// 获取等级对应配色
  static Color getColor(int level) {
    switch (level) {
      case 0:
        return const Color(0xFF9E9E9E); // 浅灰
      case 1:
        return const Color(0xFF4CAF50); // 幼苗绿
      case 2:
        return const Color(0xFF2196F3); // 进阶蓝
      case 3:
        return const Color(0xFFFF9800); // 佬友橙金
      case 4:
        return const Color(0xFFE91E63); // 元老红紫
      default:
        return const Color(0xFF607D8B);
    }
  }

  /// 获取特权描述
  static List<String> getPrivileges(int level) {
    switch (level) {
      case 0:
        return ['正常浏览社区公开帖子', '允许回复受信任等级开放的话题', '每日受发帖/回复频率保护'];
      case 1:
        return ['免除新用户大部分频率限制', '允许上传个人附件与图片', '启用站内私信与互动功能', '开放专属幼苗分区阅读权限'];
      case 2:
        return ['每日点赞与投票限额翻倍', '可使用每日邀请链接邀请新朋友', '解锁更高级别的帖子编辑和历史版本查看'];
      case 3:
        return [
          '尊贵【佬友】专属金标认证',
          '拥有重分类与重命名话题权限',
          '获得社区常青树身份，进入核心讨论区',
          '自动屏蔽低质量营销骚扰',
        ];
      case 4:
        return [
          '社区最高信任等级【元老】',
          '闭门管理与社区共治特权',
          '置顶/锁定/隐藏敏感话题权限',
          '永久不衰减的社区核心声誉',
        ];
      default:
        return ['社区活跃成员'];
    }
  }
}

class TrustLevelBadge extends StatelessWidget {
  final int level;
  final bool showTitle;
  final double? fontSize;

  const TrustLevelBadge({
    super.key,
    required this.level,
    this.showTitle = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final color = TrustLevelHelper.getColor(level);
    final title = TrustLevelHelper.getTitle(level);
    final size = fontSize ?? 10.sp;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.w,
            height: 5.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          4.hGap,
          Text(
            showTitle ? title : 'TL$level',
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

extension _IntGap on int {
  Widget get hGap => SizedBox(width: toDouble().w);
}
