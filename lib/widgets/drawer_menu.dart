import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/models/category.dart';
import 'package:linux_do/models/user.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:linux_do/utils/tag.dart';
import '../const/app_colors.dart';
import '../const/app_const.dart';
import '../const/app_images.dart';
import '../const/app_sizes.dart';
import '../const/app_spacing.dart';
import '../routes/app_pages.dart';

class DrawerMenu extends GetView<DrawerMenuController> with ToastMixin {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return SizedBox(
      width: screenWidth * 0.58,
      child: Drawer(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: 100.w + statusBarHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      AppImages.getHeaderBackground(context),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: Spacing.md,
                    bottom: Spacing.xxl,
                    right: Spacing.md,
                    child: Text.rich(
                      TextSpan(
                        text: ' \n${AppConst.siteName}',
                        style: TextStyle(
                          fontSize: AppSizes.fontLarge,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 分割线
            Divider(color: Theme.of(context).dividerColor),
            // 主要内容区域 - 使用 SafeArea 只作用于滚动内容
            Expanded(
              child: SafeArea(
                top: false, // 不处理顶部，因为我们已经手动处理了
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 外部链接
                      _buildSection(
                        context: context,
                        title: AppConst.drawerMenu.externalLinks,
                        items: [
                          MenuItem(
                            icon: CupertinoIcons.eye,
                            title: AppConst.drawerMenu.status,
                            url: AppConst.drawerMenu.statusUrl,
                          ),
                          MenuItem(
                            icon: CupertinoIcons.link,
                            title: AppConst.drawerMenu.connect,
                            url: AppConst.drawerMenu.connectUrl,
                          ),
                          MenuItem(
                            icon: CupertinoIcons.gift,
                            title: AppConst.drawerMenu.lottery,
                            url: AppConst.drawerMenu.lotteryUrl,
                          ),
                          MenuItem(
                            icon: CupertinoIcons.paperplane,
                            title: AppConst.drawerMenu.telegramChannel,
                            url: AppConst.drawerMenu.channelUrl,
                          ),
                          MenuItem(
                            icon: CupertinoIcons.paperplane,
                            title: AppConst.drawerMenu.telegram,
                            url: AppConst.drawerMenu.jaTGUrl,
                          ),
                        ],
                      ),
                      // 类别
                      Obx(
                        () => _buildSection(
                          context: context,
                          title: AppConst.drawerMenu.categories,
                          items: controller.categoryItems,
                          showViewAll: true,
                        ),
                      ),
                      // 标签
                      Obx(
                        () => _buildSection(
                          context: context,
                          title: AppConst.drawerMenu.tags,
                          items: controller.tagItems,
                          showViewAll: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<MenuItem> items,
    bool showViewAll = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Padding(
          padding: EdgeInsets.all(Spacing.sm),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppSizes.fontNormal,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              if (showViewAll) ...[
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showWarning('请在web端修改');
                  },
                  icon: Icon(
                    CupertinoIcons.pencil_circle_fill,
                    size: AppSizes.iconSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        // 菜单项
        ...items.map((item) => _buildMenuItem(context, item)),

        // 分割线
        Divider(color: Theme.of(context).dividerColor),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return InkWell(
      onTap: () {
        if (item.url != null) {
          Get.back();
          Get.toNamed(Routes.WEBVIEW, arguments: item.url);
        } else if (item.isTag) {
          Get.back();
          Get.toNamed(Routes.CATEGORY, arguments: {'tag': item.title});
        } else {
          Get.back();
          Get.toNamed(Routes.CATEGORY, arguments: item.category);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            item.icon != null
                ? Icon(
                    item.icon,
                    size: AppSizes.iconSmall,
                    color: Theme.of(context).iconTheme.color,
                  )
                : const SizedBox.shrink(),
            Spacing.md.hGap,
            Text(
              item.title,
              style: TextStyle(
                fontSize: AppSizes.fontNormal,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            if (item.hasNew) ...[
              8.hGap,
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final IconData? icon;
  final String title;
  final bool hasNew;
  final String? url;
  final Category? category;
  final bool isTag;
  const MenuItem({
    required this.icon,
    required this.title,
    this.hasNew = false,
    this.url,
    this.category,
    this.isTag = false,
  });
}

class DrawerMenuController extends GetxController {
  final GlobalController _globalController = Get.find<GlobalController>();
  final RxList<MenuItem> categoryItems = <MenuItem>[].obs;
  final RxList<MenuItem> tagItems = <MenuItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    final categoryManager = CategoryManager();
    await categoryManager.initialize();
    _loadCategories();
    _loadTags();
  }

  void _loadCategories() {
    final userInfo = _globalController.userInfo;

    final List<int> sidebarCategoryIds =
        userInfo?.user?.sidebarCategoryIds ?? [];

    categoryItems.clear();

    // 从本地加载分类数据
    final categoryManager = CategoryManager();
    for (var categoryId in sidebarCategoryIds) {
      final category = categoryManager.getCategory(categoryId);
      if (category != null) {
        categoryItems.add(
          MenuItem(
            icon: _getCategoryIcon(category.name),
            title: category.name,
            hasNew: false,
            category: category,
          ),
        );
      }
    }
  }

  void _loadTags() {
    final userInfo = _globalController.userInfo;
    final List<Tags> sidebarTags = userInfo?.user?.sidebarTags ?? [];

    tagItems.clear();

    for (var tag in sidebarTags) {
      if (tag.name != null) {
        tagItems.add(
          MenuItem(
            // TODO: 图标方案待定
            // icon: _getTagIcon(tag.name!),
            icon: null,
            title: tag.name!,
            hasNew: false,
            isTag: true,
          ),
        );
      }
    }

    l.d('Final tag items: $tagItems');
  }

  IconData _getCategoryIcon(String categoryName) {
    // 根据分类名称返回对应的图标
    switch (categoryName) {
      case '开发调优':
        return CupertinoIcons.chevron_left_slash_chevron_right;
      case '文档共建':
        return CupertinoIcons.folder;
      case '非我莫属':
        return CupertinoIcons.square_grid_2x2;
      case '扬帆起航':
        return CupertinoIcons.rocket;
      case '福利羊毛':
        return CupertinoIcons.gift;
      case '运营反馈':
        return CupertinoIcons.chat_bubble_text;
      case '资源荟萃':
        return CupertinoIcons.square_grid_3x2;
      case '跳蚤市场':
        return CupertinoIcons.cart;
      case '读书成诗':
        return CupertinoIcons.book;
      case '前沿快讯':
        return CupertinoIcons.news;
      case '摘七拾三':
        return CupertinoIcons.leaf_arrow_circlepath;
      case '深海幽域':
        return CupertinoIcons.shield;
      default:
        return CupertinoIcons.folder;
    }
  }
}
