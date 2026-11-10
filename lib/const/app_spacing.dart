import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 间距扩展
extension SpacingX on num {
  Widget get hGap => SizedBox(width: w.toDouble());
  Widget get vGap => SizedBox(height: h.toDouble());

  EdgeInsets get all => EdgeInsets.all(w.toDouble());
  EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: w.toDouble());
  EdgeInsets get vertical => EdgeInsets.symmetric(vertical: h.toDouble());
  EdgeInsets get left => EdgeInsets.only(left: w.toDouble());
  EdgeInsets get right => EdgeInsets.only(right: w.toDouble());
  EdgeInsets get top => EdgeInsets.only(top: h.toDouble());
  EdgeInsets get bottom => EdgeInsets.only(bottom: h.toDouble());
}

/// 统一间距管理
class Spacing {
  const Spacing._();

  // 基础间距
  static double get sc1 => 1.w;
  static double get sc2 => 2.w;
  static double get sc3 => 3.w;
  static double get sc4 => 4.w;
  static double get sc5 => 5.w;
  static double get sc6 => 6.w;
  static double get sc7 => 7.w;
  static double get sc8 => 8.w;
  static double get sc9 => 9.w;
  static double get sc10 => 10.w;
  static double get sc11 => 11.w;
  static double get sc12 => 12.w;
  static double get sc13 => 13.w;
  static double get sc14 => 14.w;
  static double get sc15 => 15.w;
  static double get sc16 => 16.w;
  static double get sc17 => 17.w;
  static double get sc18 => 18.w;
  static double get sc19 => 19.w;
  static double get sc20 => 20.w;
  static double get sc21 => 21.w;
  static double get sc22 => 22.w;
  static double get sc23 => 23.w;
  static double get sc24 => 24.w;
  static double get sc25 => 25.w;
  static double get sc26 => 26.w;
  static double get sc27 => 27.w;
  static double get sc28 => 28.w;
  static double get sc29 => 29.w;
  static double get sc30 => 30.w;
  static double get sc31 => 31.w;
  static double get sc32 => 32.w;
  static double get sc40 => 48.w;
  // 常用别名
  static double get xs => sc4; // 超小间距
  static double get sm => sc8; // 小间距
  static double get md => sc16; // 中间距
  static double get lg => sc24; // 大间距
  static double get xl => sc32; // 超大间距
  static double get xxl => sc40; // 超大间距
}
