import 'package:flutter/material.dart';
import 'package:memegenerator/resources/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    Key? key,
    this.onTap,
    this.icon,
    this.color = AppColors.fuchsia,
    required this.text,
  }) : super(key: key);

  final VoidCallback? onTap;
  final IconData? icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              text.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }
}
