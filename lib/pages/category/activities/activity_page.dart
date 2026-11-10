import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/activity_stream.dart';
import 'package:linux_do/widgets/state_view.dart';
import 'activity_controller.dart';

class ActivityPage extends GetView<EventController> {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConst.activity.title,
          style: TextStyle(fontSize: 16.w, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
        () => StateView(
          state: _getViewState(),
          onRetry: controller.fetchEvents,
          child: Column(
            children: [
              _buildCalendar(context),
              16.vGap,
              _buildEventList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: .1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: CalendarDatePicker2(
          config: CalendarDatePicker2Config(
            monthBuilder:
                ({
                  decoration,
                  isCurrentMonth,
                  isDisabled,
                  isSelected,
                  required month,
                  textStyle,
                }) {
                  return Center(
                    child: Text(
                      controller.monthNames[month - 1],
                      style: textStyle,
                    ),
                  );
                },
            calendarType: CalendarDatePicker2Type.range,
            selectedDayHighlightColor: Theme.of(context).primaryColor,
            weekdayLabels: ['日', '一', '二', '三', '四', '五', '六'],
            weekdayLabelTextStyle: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: AppFontFamily.dinPro,
              fontSize: 12.w,
            ),
            dayTextStyle: TextStyle(
              fontSize: 14.w,
              fontFamily: AppFontFamily.dinPro,
            ),
            selectedDayTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 14.w,
              fontWeight: FontWeight.bold,
              fontFamily: AppFontFamily.dinPro,
            ),
            todayTextStyle: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 14.w,
              fontWeight: FontWeight.bold,
              fontFamily: AppFontFamily.dinPro,
            ),
            controlsTextStyle: TextStyle(
              fontSize: 14.w,
              fontWeight: FontWeight.bold,
              fontFamily: AppFontFamily.dinPro,
            ),
          ),
          value: controller.selectedRange,
          onValueChanged: (dates) {
            if (dates.isNotEmpty) {
              controller.onDateSelected(dates.first);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEventList(BuildContext context) {
    if (controller.selectedEvents.isEmpty) {
      return Center(
        child: Text(
          AppConst.activity.noEvents,
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14.w),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.selectedEvents.length,
        separatorBuilder: (context, index) => 12.vGap,
        itemBuilder: (context, index) {
          final event = controller.selectedEvents[index];
          return _buildEventCard(context, event);
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, ActivityEvent event) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: .1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.w),
        child: InkWell(
          onTap: () => controller.onEventTap(event),
          borderRadius: BorderRadius.circular(12.w),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: TextStyle(fontSize: 16.w, fontWeight: FontWeight.bold),
                ),
                8.vGap,
                Text(
                  event.post.topic.title,
                  style: TextStyle(
                    fontSize: 14.w,
                    color: Theme.of(context).hintColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                12.vGap,
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.w,
                      color: Theme.of(context).hintColor,
                    ),
                    8.hGap,
                    Text(
                      '${AppConst.activity.startTime}: ${_formatDate(event.startsAt)}',
                      style: TextStyle(
                        fontSize: 12.w,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppConst.activity.viewDetail,
                      style: TextStyle(
                        fontSize: 12.w,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12.w,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${AppConst.activity.today} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  ViewState _getViewState() {
    if (controller.isLoading.value) {
      return ViewState.loading;
    }
    if (controller.hasError.value) {
      return ViewState.error;
    }
    // if (controller.events.isEmpty) {
    //   return ViewState.empty;
    // }
    return ViewState.content;
  }
}
