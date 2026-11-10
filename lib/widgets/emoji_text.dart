import 'package:flutter/material.dart';
import 'package:linux_do/utils/emoji_manager.dart';

class EmojiText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;

  const EmojiText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    const defaultTextStyle = TextStyle(fontSize: 20);
    return RichText(
      text: TextSpan(
        style: style ?? defaultTextStyle,
        children: parseTextWithEmojis(
          text,
          style?.fontSize ?? defaultTextStyle.fontSize,
          context,
        ),
      ),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection,
      softWrap: softWrap ?? true,
      overflow: overflow ?? TextOverflow.clip,
      maxLines: maxLines,
    );
  }
}
