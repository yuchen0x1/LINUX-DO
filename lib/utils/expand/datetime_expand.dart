extension DateTimeExpand on DateTime {
  /// 格式化日期时间
  String format([String pattern = 'yyyy-MM-dd HH:mm:ss']) {
    final year = this.year.toString();
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    final second = this.second.toString().padLeft(2, '0');

    return pattern
        .replaceAll('yyyy', year)
        .replaceAll('MM', month)
        .replaceAll('dd', day)
        .replaceAll('HH', hour)
        .replaceAll('mm', minute)
        .replaceAll('ss', second);
  }

  /// 是否是同一天
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// 是否是今天
  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  /// 是否是昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  /// 是否是明天
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(tomorrow);
  }

  /// 是否是本周
  bool get isThisWeek {
    final now = DateTime.now();
    final weekDay = now.weekday;
    final firstDayOfWeek = now.subtract(Duration(days: weekDay - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    return isAfter(firstDayOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(lastDayOfWeek.add(const Duration(days: 1)));
  }

  /// 获取友好的时间显示
  String get friendlyDateTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }

  // 超过1天就显示具体时间
  String get friendlyDateTime2 {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays > 1) {
      return format('MM-dd');
    } else {
      return format('HH:mm');
    }
  }

  // 显示年份
  String get friendlyDateTime3 {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays > 1) {
      return format('yyyy-MM-dd');
    } else {
      return format('yyyy-MM-dd');
    }
  }
}
