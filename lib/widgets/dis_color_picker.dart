import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:linux_do/widgets/dis_button.dart';

import '../const/app_colors.dart';
import '../const/app_spacing.dart';

MaterialColor primaryMaterial = AppColors.createMaterialColor(
  AppColors.primary,
);

/// 颜色选择器弹窗
class DisColorPicker {
  /// 显示颜色选择器弹窗
  /// [selectedColor] 当前选中的颜色
  /// [onColorSelected] 颜色选择回调
  static void show({
    Color? selectedColor,
    ValueChanged<Color>? onColorSelected,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(Get.context!).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Container(
          width: 0.8.sw,
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(),
              16.vGap,
              _ColorPickerContent(
                selectedColor: selectedColor,
                onColorSelected: onColorSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标题
  static Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppConst.settings.themeColor,
          style: TextStyle(
            fontSize: 15.w,
            fontWeight: FontWeight.bold,
            color: Theme.of(Get.context!).primaryColor,
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(CupertinoIcons.clear, size: 20.w),
        ),
      ],
    );
  }
}

/// 颜色选择器内容组件
class _ColorPickerContent extends StatefulWidget {
  final Color? selectedColor;
  final ValueChanged<Color>? onColorSelected;

  const _ColorPickerContent({
    Key? key,
    this.selectedColor,
    this.onColorSelected,
  }) : super(key: key);

  @override
  State<_ColorPickerContent> createState() => _ColorPickerContentState();
}

class _ColorPickerContentState extends State<_ColorPickerContent>
    with ToastMixin {
  /// 主题色列表
  static final List<MaterialColor> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    primaryMaterial,
  ];

  /// 当前选中的颜色
  late Color _currentColor;

  /// 当前选中的主题色
  MaterialColor? _currentMaterialColor;

  /// 是否显示色调选择
  bool _showShades = false;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.selectedColor ?? _colors[0];
    _currentMaterialColor = _findMaterialColor(_currentColor);
  }

  /// 查找对应的主题色
  MaterialColor? _findMaterialColor(Color color) {
    for (var materialColor in _colors) {
      if (_isShadeOfMaterialColor(materialColor, color)) {
        return materialColor;
      }
    }
    return null;
  }

  /// 判断颜色是否属于某个主题色
  bool _isShadeOfMaterialColor(MaterialColor materialColor, Color color) {
    return materialColor.value == color.value ||
        materialColor.shade50 == color ||
        materialColor.shade100 == color ||
        materialColor.shade200 == color ||
        materialColor.shade300 == color ||
        materialColor.shade400 == color ||
        materialColor.shade500 == color ||
        materialColor.shade600 == color ||
        materialColor.shade700 == color ||
        materialColor.shade800 == color ||
        materialColor.shade900 == color;
  }

  /// 获取主题色的所有色调
  List<Color> _getMaterialColorShades(MaterialColor color) {
    return [
      color.shade50,
      color.shade100,
      color.shade200,
      color.shade300,
      color.shade400,
      color.shade500,
      color.shade600,
      color.shade700,
      color.shade800,
      color.shade900,
    ];
  }

  /// 选择主题色
  void _onMaterialColorSelected(MaterialColor color) {
    setState(() {
      _currentMaterialColor = color;
      _currentColor = color;
      _showShades = true;
    });
    // widget.onColorSelected?.call(color);
  }

  /// 选择色调
  void _onShadeSelected(Color color) {
    setState(() {
      _currentColor = color;
    });
    widget.onColorSelected?.call(color);
  }

  /// 返回主题色选择
  void _onBack() {
    setState(() {
      _showShades = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showShades && _currentMaterialColor != null) ...[
            // 返回按钮
            Row(
              children: [
                IconButton(
                  onPressed: _onBack,
                  icon: Icon(
                    size: 24.w,
                    CupertinoIcons.chevron_left_circle,
                    color: Theme.of(Get.context!).primaryColor,
                  ),
                ),
              ],
            ),
            8.vGap,
            // 色调选择器
            Wrap(
              spacing: 8.w,
              runSpacing: 8.w,
              children: _getMaterialColorShades(_currentMaterialColor!)
                  .map(
                    (color) => _ColorCircle(
                      color: color,
                      isSelected: _currentColor == color,
                      onTap: () => _onShadeSelected(color),
                    ),
                  )
                  .toList(),
            ),
          ] else
            // 主题色选择器
            Wrap(
              spacing: 8.w,
              runSpacing: 8.w,
              children: _colors
                  .map(
                    (color) => _ColorCircle(
                      color: color,
                      isSelected: _currentMaterialColor == color,
                      onTap: () => _onMaterialColorSelected(color),
                    ),
                  )
                  .toList(),
            ),
          16.vGap,
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 30,
              child: DisButton(
                text: '恢复默认',
                fontSize: 12,
                borderRadius: 15,
                onPressed: () {
                  StorageManager.remove(AppConst.identifier.themeColor);
                  showSuccess('恢复成功,下次启动生效');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 颜色圆圈组件
class _ColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ColorCircle({
    Key? key,
    required this.color,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45.w,
        height: 45.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Icon(
                CupertinoIcons.checkmark_circle,
                color: Colors.white,
                size: 24.w,
              )
            : null,
      ),
    );
  }
}
