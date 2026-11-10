import 'package:flutter/material.dart';

class DisSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? textOn;
  final String? textOff;
  final Color? colorOn;
  final IconData? iconOn;
  final IconData? iconOff;
  final Duration? animationDuration;

  const DisSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.textOn,
    this.textOff,
    this.colorOn,
    this.iconOn,
    this.iconOff,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = colorOn ?? Theme.of(context).primaryColor;

    return Transform.scale(
      scale: 0.8,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        activeTrackColor: activeColor.withValues(alpha: 0.3),
        inactiveThumbColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.grey[400],
        inactiveTrackColor: Colors.grey[200],
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return activeColor;
          }
          return activeColor.withValues(alpha: 0.5);
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
