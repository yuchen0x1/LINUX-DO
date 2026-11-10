import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'birthday_controller.dart';
import 'brithday_tab_view.dart';

class BirthdayPage extends GetView<BirthdayController> {
  const BirthdayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConst.birthday.title,
          style: TextStyle(fontSize: 16.w, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: controller.tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).hintColor,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: AppConst.birthday.today),
            Tab(text: AppConst.birthday.tomorrow),
            Tab(text: AppConst.birthday.upcoming),
            Tab(text: AppConst.birthday.all),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: Filter.values
            .map((filter) => BrithdayTabView(filter: filter))
            .toList(),
      ),
    );
  }
}
