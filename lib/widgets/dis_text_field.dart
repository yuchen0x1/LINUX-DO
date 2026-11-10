import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DisTextField extends StatelessWidget {
  final String? value;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final bool enabled;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;
  final TextEditingController? controller;

  const DisTextField({
    super.key,
    this.value,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.focusNode,
    this.onEditingComplete,
    this.onSubmitted,
    this.style,
    this.hintStyle,
    this.contentPadding,
    this.fillColor,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.disabledBorder,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.w),
      borderSide: BorderSide(
        color: Theme.of(context).dividerColor,
      ),
    );

    return TextField(
      controller: controller ?? TextEditingController(text: value)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: value?.length ?? 0),
        ),
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
      style: style ??
          TextStyle(
            fontSize: 14.w,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle ??
            TextStyle(
              fontSize: 14.w,
              color: Theme.of(context).hintColor,
            ),
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.w,
            ),
        filled: true,
        fillColor: fillColor ?? Theme.of(context).cardColor,
        border: border ?? defaultBorder,
        enabledBorder: enabledBorder ?? defaultBorder,
        focusedBorder: focusedBorder ??
            defaultBorder.copyWith(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
        disabledBorder: disabledBorder ??
            defaultBorder.copyWith(
              borderSide: BorderSide(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              ),
            ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
    );
  }
}
