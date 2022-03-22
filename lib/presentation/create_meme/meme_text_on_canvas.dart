import 'package:flutter/material.dart';
import 'package:memegenerator/resources/app_colors.dart';

class MemeTextOnCanvas extends StatelessWidget {
  const MemeTextOnCanvas({
    Key? key,
    required this.selected,
    required this.padding,
    required this.fontSize,
    required this.fontWeight,
    required this.parentConstraints,
    required this.text,
    required this.color,
  }) : super(key: key);

  final bool selected;
  final double padding;
  final double fontSize;
  final FontWeight fontWeight;
  final String text;
  final Color color;
  final BoxConstraints parentConstraints;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: parentConstraints.maxWidth,
        maxHeight: parentConstraints.maxHeight,
      ),
      decoration: BoxDecoration(
        color: selected ? AppColors.darkGrey16 : null,
        border: Border.all(
          color: selected ? AppColors.fuchsia : Colors.transparent,
        ),
      ),
      padding: EdgeInsets.all(padding),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style:
            TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight),
      ),
    );
  }
}
