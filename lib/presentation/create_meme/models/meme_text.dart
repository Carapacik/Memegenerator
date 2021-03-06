import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memegenerator/data/models/text_with_position.dart';
import 'package:uuid/uuid.dart';

class MemeText extends Equatable {
  const MemeText({
    required this.id,
    required this.text,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
  });

  factory MemeText.createFromTextWithPosition(
    final TextWithPosition textWithPosition,
  ) =>
      MemeText(
        id: textWithPosition.id,
        text: textWithPosition.text,
        color: textWithPosition.color ?? defaultColor,
        fontSize: textWithPosition.fontSize ?? defaultFontSize,
        fontWeight: textWithPosition.fontWeight ?? defaultFontWeight,
      );

  factory MemeText.create() => MemeText(
        id: const Uuid().v4(),
        text: '',
        color: defaultColor,
        fontSize: defaultFontSize,
        fontWeight: defaultFontWeight,
      );

  static const defaultColor = Colors.black;
  static const defaultFontSize = 24.0;
  static const defaultFontWeight = FontWeight.w400;

  final String id;
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  MemeText copyWithChangedFontSetting(
    final Color newColor,
    final double newFontSize,
    final FontWeight newFontWeight,
  ) =>
      MemeText(
        id: id,
        text: text,
        color: newColor,
        fontSize: newFontSize,
        fontWeight: newFontWeight,
      );

  MemeText copyWithChangedText(final String newText) => MemeText(
        id: id,
        text: newText,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      );

  @override
  List<Object?> get props => [id, text, color, fontSize, fontWeight];
}
