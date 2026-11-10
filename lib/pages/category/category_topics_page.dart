import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:slide_switcher/slide_switcher.dart';
import '../../const/app_colors.dart';
import '../../const/app_const.dart';
import '../../widgets/drawer_menu.dart';
import '../../widgets/sticky_tab_delegate.dart';
import '../../widgets/text_scroll.dart';
import 'category_topics_controller.dart';

class CategoryTopicsPage extends GetView<CategoryTopicsController> {
  const CategoryTopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: const DrawerMenu(),
      body: NestedScrollView(
        physics: const ClampingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              leading: SizedBox(
                width: 40.w,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.menu_rounded,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    controller.scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // tishi
                  _buildBanner(context),
                  // 菜单按钮
                  _buildMenuButtons(context),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyTabBarDelegate(
                height: 46.w,
                child: Container(
                  color: AppColors.transparent,
                  margin: EdgeInsets.symmetric(vertical: 6.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SlideSwitcher(
                    containerHeight: 46.w,
                    containerWight: MediaQuery.of(context).size.width - 32.w,
                    containerBorderRadius: 4.w,
                    initialIndex: controller.currentTabIndex,
                    containerBorder: Border.all(
                        width: .4, color: Theme.of(context).primaryColor),
                    containerColor: Theme.of(context).cardColor,
                    containerBoxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .shadowColor
                            .withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                    slidersGradients: [
                      LinearGradient(colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: .6)
                      ])
                    ],
                    onSelect: (index) => controller.currentTabIndex = index,
                    children: [
                      _buildTabText('我的帖子', 0),
                      _buildTabText('我的书签', 1),
                      _buildTabText('文章', 2),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        // 列表内容
        body: Obx(() => controller.createCurrent()),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return SizedBox(
      height: 40.w,
      width: double.infinity,
      child: Center(
        child: TextScroll(
          AppConst.slogan.replaceAll('\n', ' '),
          style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
          mode: TextScrollMode.endless,
          intervalSpaces: 10,
          velocity: const Velocity(pixelsPerSecond: Offset(80, 0)),
          selectable: true,
          fadedBorder: true,
          fadedBorderWidth: 0.2,
          fadeBorderSide: FadeBorderSide.both,
        ),
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Container(
      height: 180.w,
      margin: EdgeInsets.symmetric(vertical: 10.w),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 6.w,
          crossAxisSpacing: 6.w,
          childAspectRatio: 2,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.menuItems.length,
        itemBuilder: (context, index) {
          final item = controller.menuItems[index];
          return InkWell(
            onTap: () => controller.onMenuTap(index),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: item['colors'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12.w,
                    left: 16.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 18.w,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12.w,
                            color: Colors.white.withValues(alpha: .6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -34.w,
                    bottom: -20.w,
                    child: Icon(
                      item['icon'] as IconData,
                      color: AppColors.white.withValues(alpha: .15),
                      size: 108.w,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabText(String text, int index) {
    final context = Get.context!;
    return Obx(() => Text(
          text,
          style: TextStyle(
            fontSize: 14.w,
            color: controller.currentTabIndex == index
                ? AppColors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ));
  }
}
