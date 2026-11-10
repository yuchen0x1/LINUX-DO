// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:html2md/html2md.dart' as html2md;
// import 'package:linux_do/routes/app_pages.dart';
// import 'package:url_launcher/url_launcher_string.dart';

// class MarkdownWidget extends StatelessWidget {
//   final String html;
//   final double? fontSize;
//   final ScrollPhysics? physics;
//   final EdgeInsetsGeometry? padding;
//   final bool selectable;

//   const MarkdownWidget({
//     super.key,
//     required this.html,
//     this.fontSize,
//     this.physics,
//     this.padding,
//     this.selectable = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // 将HTML转换为Markdown
//     final markdown = html2md.convert(html);

//     final markdownWidget = MarkdownBody(
//       data: markdown,
//       selectable: selectable,
//       styleSheet: MarkdownStyleSheet(
//         p: TextStyle(
//           fontSize: fontSize ?? 14.sp,
//           height: 1.5,
//           color: Theme.of(context).textTheme.bodyMedium?.color,
//         ),
//         h1: TextStyle(
//           fontSize: 24.sp,
//           fontWeight: FontWeight.bold,
//           height: 1.5,
//           color: Theme.of(context).textTheme.titleLarge?.color,
//         ),
//         h2: TextStyle(
//           fontSize: 20.sp,
//           fontWeight: FontWeight.bold,
//           height: 1.5,
//           color: Theme.of(context).textTheme.titleLarge?.color,
//         ),
//         h3: TextStyle(
//           fontSize: 18.sp,
//           fontWeight: FontWeight.bold,
//           height: 1.5,
//           color: Theme.of(context).textTheme.titleLarge?.color,
//         ),
//         h4: TextStyle(
//           fontSize: 16.sp,
//           fontWeight: FontWeight.bold,
//           height: 1.5,
//           color: Theme.of(context).textTheme.titleLarge?.color,
//         ),
//         h5: TextStyle(
//           fontSize: 14.sp,
//           fontWeight: FontWeight.bold,
//           height: 1.5,
//           color: Theme.of(context).textTheme.titleLarge?.color,
//         ),
//         h6: TextStyle(
//           fontSize: 12.sp,
//           fontWeight: FontWeight.bold,
//           height: 1.5,
//           color: Theme.of(context).textTheme.titleLarge?.color,
//         ),
//         em: TextStyle(
//           fontStyle: FontStyle.italic,
//           color: Theme.of(context).textTheme.bodyMedium?.color,
//         ),
//         strong: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Theme.of(context).textTheme.bodyMedium?.color,
//         ),
//         code: TextStyle(
//           fontSize: 13.sp,
//           fontFamily: 'monospace',
//           color: Theme.of(context).primaryColor,
//           backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
//         ),
//         blockquote: TextStyle(
//           fontSize: fontSize ?? 14.sp,
//           height: 1.5,
//           color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
//         ),
//         blockquoteDecoration: BoxDecoration(
//           border: Border(
//             left: BorderSide(
//               color: Theme.of(context).primaryColor.withOpacity(0.5),
//               width: 4.w,
//             ),
//           ),
//           color: Theme.of(context).primaryColor.withOpacity(0.05),
//         ),
//         blockSpacing: 16.w,
//         listIndent: 24.w,
//         listBullet: TextStyle(
//           fontSize: fontSize ?? 14.sp,
//           color: Theme.of(context).textTheme.bodyMedium?.color,
//         ),
//         tableBody: TextStyle(
//           fontSize: fontSize ?? 14.sp,
//           color: Theme.of(context).textTheme.bodyMedium?.color,
//         ),
//         tableHead: TextStyle(
//           fontSize: fontSize ?? 14.sp,
//           fontWeight: FontWeight.bold,
//           color: Theme.of(context).textTheme.bodyMedium?.color,
//         ),
//         tableBorder: TableBorder.all(
//           color: Theme.of(context).dividerColor,
//           width: 1,
//         ),
//         tableColumnWidth: const FlexColumnWidth(),
//         tableCellsPadding: EdgeInsets.all(8.w),
//         // tableBodyDecoration: BoxDecoration(
//         //   color: Theme.of(context).cardColor,
//         // ),
//         // tableHeadDecoration: BoxDecoration(
//         //   color: Theme.of(context).primaryColor.withOpacity(0.1),
//         // ),
//       ),
//       onTapLink: (text, href, title) {
//         if (href == null) return;

//         if (href.startsWith('http') || href.startsWith('https')) {
//           Get.toNamed(Routes.WEBVIEW, arguments: href);
//         } else {
//           launchUrlString(href, mode: LaunchMode.externalApplication);
//         }
//       },
//     );

//     if (padding != null) {
//       return SingleChildScrollView(
//         physics: physics,
//         padding: padding,
//         child: markdownWidget,
//       );
//     }

//     return markdownWidget;
//   }
// }
