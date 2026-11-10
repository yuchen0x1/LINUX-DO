extension NumExpand on num {
  /// 转换为价格字符串，保留两位小数
  String toPrice() => toStringAsFixed(2);

  /// 转换为千分位格式
  String toThousands() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 数字转中文
  String toChineseNumber() {
    const List<String> cnNums = [
      '零',
      '一',
      '二',
      '三',
      '四',
      '五',
      '六',
      '七',
      '八',
      '九',
    ];
    const List<String> cnUnits = ['', '十', '百', '千', '万', '十', '百', '千', '亿'];

    String numStr = toInt().toString();
    String result = '';

    for (int i = 0; i < numStr.length; i++) {
      int num = int.parse(numStr[i]);
      int pos = numStr.length - i - 1;
      result += cnNums[num] + cnUnits[pos];
    }

    return result;
  }

  // 数字转千分位
  String toThousandsUnit() {
    if (this >= 1000) {
      double value = this / 1000;
      return '${value.toStringAsFixed(1)}k';
    }
    return toString();
  }
}
