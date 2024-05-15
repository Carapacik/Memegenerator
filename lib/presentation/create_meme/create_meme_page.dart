import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memegenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memegenerator/presentation/create_meme/font_settings_bottom_sheet.dart';
import 'package:memegenerator/presentation/create_meme/meme_text_on_canvas.dart';
import 'package:memegenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memegenerator/presentation/create_meme/models/meme_text_with_offset.dart';
import 'package:memegenerator/presentation/create_meme/models/meme_text_with_selection.dart';
import 'package:memegenerator/presentation/widgets/app_button.dart';
import 'package:memegenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class CreateMemePage extends StatefulWidget {
  const CreateMemePage({
    this.selectedMemePath,
    this.id,
    super.key,
  });

  final String? id;
  final String? selectedMemePath;

  @override
  _CreateMemePageState createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = CreateMemeBloc(
      id: widget.id,
      selectedMemePath: widget.selectedMemePath,
    );
  }

  @override
  Widget build(BuildContext context) => Provider.value(
        value: bloc,
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) {
              return;
            }
            final navigator = Navigator.of(context);
            final allSaved = await bloc.isAllSaved();
            if (allSaved) {
              return navigator.pop();
            }
            if (context.mounted) {
              final goBack = await showConfirmationExitDialog(context);

              if (goBack ?? false) {
                navigator.pop();
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: AppColors.lemon,
              foregroundColor: AppColors.darkGrey,
              title: const Text('Создать мем'),
              bottom: const EditTextBar(),
              actions: [
                AnimatedIconButton(
                  onTap: () async => bloc.shareMeme(),
                  icon: Icons.share,
                ),
                AnimatedIconButton(
                  onTap: () async => bloc.saveMeme(),
                  icon: Icons.save,
                ),
              ],
            ),
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: const SafeArea(
              child: CreateMemePageContent(),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    unawaited(bloc.dispose());
    super.dispose();
  }

  Future<bool?> showConfirmationExitDialog(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Хотите выйти?'),
          content: const Text('Вы потеряете несохранённые изменения'),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
          actions: [
            AppButton(
              onTap: () => Navigator.of(context).pop(false),
              text: 'Отмена',
              color: AppColors.darkGrey,
            ),
            AppButton(
              onTap: () => Navigator.of(context).pop(true),
              text: 'Выйти',
            ),
          ],
        ),
      );
}

class AnimatedIconButton extends StatefulWidget {
  const AnimatedIconButton({
    required this.onTap,
    required this.icon,
    super.key,
  });

  final VoidCallback onTap;
  final IconData icon;

  @override
  _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> {
  double scale = 1;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          setState(() => scale = 1.5);
          widget.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: scale,
            curve: Curves.bounceInOut,
            child: Icon(
              widget.icon,
              color: AppColors.darkGrey,
              size: 24,
            ),
            onEnd: () => setState(() => scale = 1),
          ),
        ),
      );
}

class EditTextBar extends StatefulWidget implements PreferredSizeWidget {
  const EditTextBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  State<EditTextBar> createState() => _EditTextBarState();
}

class _EditTextBarState extends State<EditTextBar> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: StreamBuilder<MemeText?>(
        stream: bloc.observeSelectedMemeTexts(),
        builder: (context, snapshot) {
          final selectedMemeText =
              snapshot.hasData ? snapshot.requireData : null;
          if (selectedMemeText?.text != controller.text) {
            final newText = selectedMemeText?.text ?? '';
            controller
              ..text = newText
              ..selection = TextSelection.collapsed(offset: newText.length);
          }
          final haveSelected = selectedMemeText != null;

          return TextField(
            enabled: haveSelected,
            controller: controller,
            onChanged: (text) {
              if (haveSelected) {
                bloc.changeMemeText(selectedMemeText.id, text);
              }
            },
            onEditingComplete: bloc.deselectMemeText,
            cursorColor: AppColors.fuchsia,
            decoration: InputDecoration(
              filled: true,
              hintText: haveSelected ? 'Ввести текст' : null,
              hintStyle: TextStyle(fontSize: 16, color: AppColors.darkGrey38),
              fillColor:
                  haveSelected ? AppColors.fuchsia16 : AppColors.darkGrey6,
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.darkGrey38),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.fuchsia38),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.fuchsia, width: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CreateMemePageContent extends StatefulWidget {
  const CreateMemePageContent({super.key});

  @override
  _CreateMemePageContentState createState() => _CreateMemePageContentState();
}

class _CreateMemePageContentState extends State<CreateMemePageContent> {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Expanded(
            flex: 2,
            child: MemeCanvasWidget(),
          ),
          Container(
            height: 1,
            color: AppColors.darkGrey,
          ),
          const Expanded(child: BottomList()),
        ],
      );
}

class BottomList extends StatelessWidget {
  const BottomList({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return ColoredBox(
      color: Colors.white,
      child: StreamBuilder<List<MemeTextWithSelection>>(
        stream: bloc.observeSelectedMemeTextsWithSelection(),
        initialData: const <MemeTextWithSelection>[],
        builder: (context, snapshot) {
          final items = snapshot.hasData
              ? snapshot.data!
              : const <MemeTextWithSelection>[];

          return ListView.separated(
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: AppButton(
                      text: 'Добавить текст',
                      onTap: bloc.addNewText,
                      icon: Icons.add,
                    ),
                  ),
                );
              }
              final item = items[index - 1];

              return BottomMemeText(item: item);
            },
            separatorBuilder: (context, index) {
              if (index == 0) {
                return const SizedBox.shrink();
              }

              return const BottomSeparator();
            },
          );
        },
      ),
    );
  }
}

class BottomSeparator extends StatelessWidget {
  const BottomSeparator({super.key});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 16),
        color: AppColors.darkGrey,
        height: 1,
      );
}

class BottomMemeText extends StatelessWidget {
  const BottomMemeText({
    required this.item,
    super.key,
  });

  final MemeTextWithSelection item;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => bloc.selectMemeText(item.memeText.id),
      child: Container(
        height: 48,
        alignment: Alignment.centerLeft,
        color: item.selected ? AppColors.darkGrey16 : null,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.memeText.text,
                style: const TextStyle(color: AppColors.darkGrey, fontSize: 16),
              ),
            ),
            const SizedBox(width: 4),
            BottomMemeTextAction(
              onTap: () async => showModalBottomSheet<void>(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                builder: (context) => Provider.value(
                  value: bloc,
                  child: FontSettingBottomSheet(memeText: item.memeText),
                ),
              ),
              icon: Icons.font_download_outlined,
            ),
            const SizedBox(width: 4),
            BottomMemeTextAction(
              onTap: () {
                bloc.deleteMemeText(item.memeText.id);
              },
              icon: Icons.delete_forever_outlined,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class BottomMemeTextAction extends StatelessWidget {
  const BottomMemeTextAction({
    required this.icon,
    this.onTap,
    super.key,
  });

  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon),
        ),
      );
}

class MemeCanvasWidget extends StatelessWidget {
  const MemeCanvasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return Container(
      color: AppColors.darkGrey38,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1,
        child: StreamBuilder<ScreenshotController>(
          stream: bloc.observeScreenshotController(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            return Screenshot(
              controller: snapshot.requireData,
              child: const Stack(
                children: [
                  BackgroundImage(),
                  MemeTexts(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MemeTexts extends StatelessWidget {
  const MemeTexts({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return StreamBuilder<List<MemeTextWithOffset>>(
      initialData: const <MemeTextWithOffset>[],
      stream: bloc.observeMemeTextsWithOffsets(),
      builder: (context, snapshot) {
        final memeTextWithOffsets =
            snapshot.hasData ? snapshot.data! : const <MemeTextWithOffset>[];

        return LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: bloc.deselectMemeText,
            child: Stack(
              children: memeTextWithOffsets
                  .map(
                    (elem) => DraggableMemeText(
                      key: ValueKey(elem.memeText.id),
                      memeTextWithOffset: elem,
                      parentConstraints: constraints,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return StreamBuilder<String?>(
      stream: bloc.observeMemePath(),
      builder: (context, snapshot) {
        final path = snapshot.hasData ? snapshot.data : null;
        if (path == null) {
          return const ColoredBox(color: Colors.white);
        }

        return Image.file(File(path));
      },
    );
  }
}

class DraggableMemeText extends StatefulWidget {
  const DraggableMemeText({
    required this.memeTextWithOffset,
    required this.parentConstraints,
    super.key,
  });

  final MemeTextWithOffset memeTextWithOffset;
  final BoxConstraints parentConstraints;

  @override
  State<DraggableMemeText> createState() => _DraggableMemeTextState();
}

class _DraggableMemeTextState extends State<DraggableMemeText> {
  late double top;
  late double left;
  final double padding = 8;

  @override
  void initState() {
    left = widget.memeTextWithOffset.offset?.dx ??
        widget.parentConstraints.maxWidth / 3;
    top = widget.memeTextWithOffset.offset?.dy ??
        widget.parentConstraints.maxHeight / 2;
    if (widget.memeTextWithOffset.offset == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Provider.of<CreateMemeBloc>(context, listen: false)
            .changeMemeTextOffset(
          widget.memeTextWithOffset.memeText.id,
          Offset(left, top),
        );
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => bloc.selectMemeText(widget.memeTextWithOffset.memeText.id),
        onPanUpdate: (details) {
          bloc.selectMemeText(widget.memeTextWithOffset.memeText.id);
          setState(() {
            left = calculateLeft(details);
            top = calculateTop(details);
            bloc.changeMemeTextOffset(
              widget.memeTextWithOffset.memeText.id,
              Offset(left, top),
            );
          });
        },
        child: StreamBuilder<MemeText?>(
          stream: bloc.observeSelectedMemeTexts(),
          builder: (context, snapshot) {
            final selectedItem = snapshot.hasData ? snapshot.data : null;
            final selected =
                widget.memeTextWithOffset.memeText.id == selectedItem?.id;

            return MemeTextOnCanvas(
              selected: selected,
              padding: padding,
              parentConstraints: widget.parentConstraints,
              text: widget.memeTextWithOffset.memeText.text,
              fontSize: widget.memeTextWithOffset.memeText.fontSize,
              fontWeight: widget.memeTextWithOffset.memeText.fontWeight,
              color: widget.memeTextWithOffset.memeText.color,
            );
          },
        ),
      ),
    );
  }

  double calculateTop(DragUpdateDetails details) {
    final rawTop = top + details.delta.dy;
    if (rawTop < 0) {
      return 0;
    }
    if (rawTop > widget.parentConstraints.maxHeight - padding * 2 - 30) {
      return widget.parentConstraints.maxHeight - padding * 2 - 30;
    }

    return rawTop;
  }

  double calculateLeft(DragUpdateDetails details) {
    final rawLeft = left + details.delta.dx;
    if (rawLeft < 0) {
      return 0;
    }
    if (rawLeft > widget.parentConstraints.maxWidth - padding * 2 - 10) {
      return widget.parentConstraints.maxWidth - padding * 2 - 10;
    }

    return rawLeft;
  }
}
