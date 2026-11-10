import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';

class CodePreviewDialog extends StatelessWidget with ToastMixin {
  final String code;
  final String? language;

  const CodePreviewDialog({
    super.key,
    required this.code,
    this.language,
  });

  @override
  Widget build(BuildContext context) {
    // 构建 markdown 格式的代码块
    final markdownCode = '''```${language ?? ''}
$code
```''';

    return Dialog.fullscreen(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // 顶部工具栏
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 36.w),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      CupertinoIcons.clear,
                      size: 20.w,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  12.hGap,
                  if (language != null) ...[
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: Text(
                        language!,
                        style: TextStyle(
                          fontSize: 12.w,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      showSuccess('代码已复制到剪贴板');
                    },
                    icon: Icon(
                      CupertinoIcons.doc_on_doc,
                      size: 20.w,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 代码内容
          Expanded(
            child: SelectionArea(
              child: Markdown(
                data: markdownCode,
                selectable: true,
                padding: EdgeInsets.all(16.w),
                styleSheet:
                    MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'monospace',
                    height: 1.5,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  code: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'monospace',
                    height: 1.5,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    backgroundColor: Colors.transparent,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  codeblockPadding: EdgeInsets.all(12.w),
                  blockquote: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'monospace',
                    height: 1.5,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  blockquotePadding: EdgeInsets.all(12.w),
                ),
                syntaxHighlighter: null, // 使用默认的语法高亮
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示代码预览弹窗的便捷方法
void showCodePreview(BuildContext context, String code, {String? language}) {
  Get.dialog(
    CodePreviewDialog(
      code: code,
      language: language,
    ),
    useSafeArea: false,
  );
}
