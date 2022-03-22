import 'package:flutter/material.dart';
import 'package:memegenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memegenerator/presentation/create_meme/meme_text_on_canvas.dart';
import 'package:memegenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memegenerator/presentation/widgets/app_button.dart';
import 'package:memegenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

class FontSettingBottomSheet extends StatefulWidget {
  const FontSettingBottomSheet({
    Key? key,
    required this.memeText,
  }) : super(key: key);

  final MemeText memeText;

  @override
  State<FontSettingBottomSheet> createState() => _FontSettingBottomSheetState();
}

class _FontSettingBottomSheetState extends State<FontSettingBottomSheet> {
  late double fontSize;
  late Color color;
  late FontWeight fontWeight;

  @override
  void initState() {
    fontSize = widget.memeText.fontSize;
    color = widget.memeText.color;
    fontWeight = widget.memeText.fontWeight;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 64,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkGrey38,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        MemeTextOnCanvas(
          selected: true,
          padding: 8,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          parentConstraints: const BoxConstraints.expand(),
          text: widget.memeText.text,
        ),
        const SizedBox(height: 48),
        FontSizeSlider(
          initialFontSize: fontSize,
          changeFontSize: (value) {
            setState(() => fontSize = value);
          },
        ),
        const SizedBox(height: 24),
        ColorSelection(
          changeColor: (value) {
            setState(() => color = value);
          },
        ),
        const SizedBox(height: 24),
        FontWeightSlider(
          initialFontWeight: fontWeight,
          changeFontWeight: (value) {
            setState(() => fontWeight = value);
          },
        ),
        const SizedBox(height: 36),
        Align(
          alignment: Alignment.centerRight,
          child: Buttons(
            onPositiveButtonAction: () {
              bloc.changeFontSetting(
                widget.memeText.id,
                color,
                fontSize,
                fontWeight,
              );
              Navigator.of(context).pop();
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class Buttons extends StatelessWidget {
  const Buttons({
    Key? key,
    this.onPositiveButtonAction,
  }) : super(key: key);

  final VoidCallback? onPositiveButtonAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          onTap: () => Navigator.of(context).pop(),
          text: "Отмена",
          color: AppColors.darkGrey,
        ),
        const SizedBox(width: 24),
        AppButton(
          onTap: onPositiveButtonAction,
          text: "Сохранить",
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class ColorSelection extends StatelessWidget {
  const ColorSelection({
    Key? key,
    required this.changeColor,
  }) : super(key: key);

  final ValueChanged<Color> changeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 16),
        const Text(
          "Color",
          style: TextStyle(fontSize: 20, color: AppColors.darkGrey),
        ),
        const SizedBox(width: 16),
        ColorSelectionBox(changeColor: changeColor, color: Colors.white),
        const SizedBox(width: 16),
        ColorSelectionBox(changeColor: changeColor, color: Colors.black),
      ],
    );
  }
}

class ColorSelectionBox extends StatelessWidget {
  const ColorSelectionBox({
    Key? key,
    required this.changeColor,
    required this.color,
  }) : super(key: key);

  final ValueChanged<Color> changeColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => changeColor(color),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(),
        ),
      ),
    );
  }
}

class FontSizeSlider extends StatefulWidget {
  const FontSizeSlider({
    Key? key,
    required this.changeFontSize,
    required this.initialFontSize,
  }) : super(key: key);

  final ValueChanged<double> changeFontSize;
  final double initialFontSize;

  @override
  State<FontSizeSlider> createState() => _FontSizeSliderState();
}

class _FontSizeSliderState extends State<FontSizeSlider> {
  late double fontSize;

  @override
  void initState() {
    fontSize = widget.initialFontSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            "Size",
            style: TextStyle(fontSize: 20, color: AppColors.darkGrey),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.fuchsia,
              inactiveTrackColor: AppColors.fuchsia38,
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
              thumbColor: AppColors.fuchsia,
              inactiveTickMarkColor: AppColors.fuchsia,
              valueIndicatorColor: AppColors.fuchsia,
            ),
            child: Slider(
              min: 16,
              max: 32,
              divisions: 10,
              label: fontSize.round().toString(),
              value: fontSize,
              onChanged: (double value) {
                setState(() {
                  fontSize = value;
                  widget.changeFontSize(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class FontWeightSlider extends StatefulWidget {
  const FontWeightSlider({
    Key? key,
    required this.changeFontWeight,
    required this.initialFontWeight,
  }) : super(key: key);

  final ValueChanged<FontWeight> changeFontWeight;
  final FontWeight initialFontWeight;

  @override
  State<FontWeightSlider> createState() => _FontWeightSliderState();
}

class _FontWeightSliderState extends State<FontWeightSlider> {
  late FontWeight fontWeight;

  @override
  void initState() {
    fontWeight = widget.initialFontWeight;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            "Font Weight:",
            style: TextStyle(fontSize: 20, color: AppColors.darkGrey),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.fuchsia,
              inactiveTrackColor: AppColors.fuchsia38,
              thumbColor: AppColors.fuchsia,
              inactiveTickMarkColor: AppColors.fuchsia,
              valueIndicatorColor: AppColors.fuchsia,
            ),
            child: Slider(
              min: FontWeight.w100.index.toDouble(),
              max: FontWeight.w900.index.toDouble(),
              divisions: FontWeight.w900.index - FontWeight.w100.index,
              value: fontWeight.index.toDouble(),
              onChanged: (value) {
                setState(() {
                  fontWeight = FontWeight.values
                      .firstWhere((fw) => fw.index == value.toInt());
                  widget.changeFontWeight(fontWeight);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
