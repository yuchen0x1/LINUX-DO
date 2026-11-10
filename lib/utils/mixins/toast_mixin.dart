import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

enum SnackbarType { info, success, error, warning }

mixin ToastMixin {
  /// 显示toast提示
  void showToast(
    String message, {
    Toast length = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.CENTER,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    double fontSize = 16.0,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  /// 显示成功toast
  void showSuccess(String message) {
    showToast(message, backgroundColor: Colors.green);
  }

  /// 显示错误toast
  void showError(String message) {
    showToast(message, backgroundColor: Colors.red);
  }

  /// 显示警告toast
  void showWarning(String message) {
    showToast(message, backgroundColor: Colors.orange);
  }

  // 显示Snackbar
  void showSnackbar({
    required String title,
    required String message,
    SnackbarType type = SnackbarType.info,
  }) {
    Color backgroundColor;
    IconData iconData;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green;
        iconData = CupertinoIcons.checkmark_square_fill;
        break;
      case SnackbarType.error:
        backgroundColor = Colors.red;
        iconData = CupertinoIcons.multiply_circle_fill;
        break;
      case SnackbarType.warning:
        backgroundColor = const Color(0xFFCFA313);
        iconData = CupertinoIcons.exclamationmark_triangle_fill;
      default:
        backgroundColor = Colors.blue;
        iconData = CupertinoIcons.captions_bubble_fill;
    }

    Get.snackbar(
      title,
      message,
      duration: const Duration(milliseconds: 1800),
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      borderRadius: 4.w,
      margin: EdgeInsets.all(14.w),
      icon: Icon(iconData, color: Colors.white),
      boxShadows: [BoxShadow(color: Colors.black26, blurRadius: 4.w)],
    );
  }
}
