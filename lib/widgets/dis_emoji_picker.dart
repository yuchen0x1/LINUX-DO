import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/utils/emoji_manager.dart';
import '../const/app_colors.dart';

class DisEmojiPicker extends StatelessWidget {
  final double? height;
  final double? emojiSize;
  final bool showBackspace;
  final Color? backgroundColor;
  final TextEditingController? textEditingController;
  final Function(String)? onEmojiSelected;

  const DisEmojiPicker({
    super.key,
    this.height,
    this.emojiSize,
    this.showBackspace = false,
    this.backgroundColor,
    this.textEditingController,
    this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 356.w,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _onEmojiSelected(emoji);
        },
        config: Config(
          height: height ?? 356.w,
          emojiSet: (locale) => EmojiManager().getCategoryEmojis(),
          emojiViewConfig: EmojiViewConfig(
            columns: 7,
            emojiSizeMax: emojiSize ?? 30.w,
            backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
          ),
          categoryViewConfig: CategoryViewConfig(
            // 默认的是真的丑  必须自定义
            customCategoryView: (config, state, tabController, pageController) {
              return _buildCustomCategory(
                context,
                tabController,
                pageController,
                state,
                config,
              );
            },
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            enabled: showBackspace,
            showBackspaceButton: showBackspace,
            backgroundColor:
                backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCategory(
    BuildContext context,
    TabController tabController,
    PageController pageController,
    EmojiViewState state,
    Config config,
  ) {
    final ValueNotifier<int> tabIndexNotifier = ValueNotifier<int>(
      tabController.index,
    );
    tabController.addListener(() {
      tabIndexNotifier.value = tabController.index;
    });

    return ValueListenableBuilder<int>(
      valueListenable: tabIndexNotifier,
      builder: (context, currentIndex, child) {
        return Container(
          height: 44.w,
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          padding: EdgeInsets.zero,
          child: TabBar(
            tabAlignment: TabAlignment.start,
            controller: tabController,
            isScrollable: true,
            padding: EdgeInsets.zero,
            onTap: (index) {
              pageController.jumpToPage(index);
            },
            dividerHeight: 0,
            indicatorPadding: EdgeInsets.zero,
            indicator: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .9),
              shape: BoxShape.circle,
            ),
            labelPadding: EdgeInsets.zero,
            tabs: state.categoryEmoji.map((category) {
              final icon = getIconForCategory(
                config.categoryViewConfig.categoryIcons,
                category.category,
              );
              final isSelected =
                  tabController.index == state.categoryEmoji.indexOf(category);
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                child: Icon(
                  icon,
                  size: 20.w,
                  color: isSelected
                      ? AppColors.white
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _onEmojiSelected(Emoji emoji) {
    if (emoji.imageUrl != null) {
      textEditingController?.text += ':${emoji.name}:';
      onEmojiSelected?.call(':${emoji.name}:');
    } else {
      textEditingController?.text += emoji.emoji;
      onEmojiSelected?.call(emoji.emoji);
    }
  }
}
