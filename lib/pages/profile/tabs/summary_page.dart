import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/widgets/state_view.dart';
import 'summary_controller.dart';

class SummaryPage extends GetView<SummaryController> {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => StateView(
          state: controller.getViewState(),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatSection(
                context,
                title: '基础统计',
                items: controller.topStats.value ?? [],
              ),
              _buildStatSection(
                context,
                title: '互动数据',
                items: controller.bottomStats.value ?? [],
              ),
            ],
          ),
        ));
  }

  Widget _buildStatSection(BuildContext context,
      {required String title, required List<StatItem> items}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(top: 8.w, bottom: 16.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.w,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            14.vGap,
            _buildStatList(context, items),
          ],
        ),
      ),
    );
  }

  Widget _buildStatList(BuildContext context, List<StatItem> items) {
    return Column(
      children: items
          .map((item) => Padding(
                padding: EdgeInsets.only(bottom: 12.w),
                child: _StatItem(item: item),
              ))
          .toList(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final StatItem item;

  const _StatItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 6.w, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: (item.iconColor ?? Theme.of(context).primaryColor)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Icon(
                item.icon,
                color: item.iconColor ?? Theme.of(context).primaryColor,
                size: 20.w,
              ),
            ),
            12.hGap,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12.w,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 12.w,
              fontFamily: AppFontFamily.dinPro,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
