import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memegenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memegenerator/presentation/easter_egg/easter_egg_page.dart';
import 'package:memegenerator/presentation/main/main_bloc.dart';
import 'package:memegenerator/presentation/main/models/meme_thumbnail.dart';
import 'package:memegenerator/presentation/main/models/template_full.dart';
import 'package:memegenerator/presentation/widgets/app_button.dart';
import 'package:memegenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late MainBloc bloc;
  late TabController tabController;
  double tabIndex = 0;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();
    bloc.checkForAndroidUpdate();
    tabController = TabController(length: 2, vsync: this);
    tabController.animation!.addListener(() {
      setState(() => tabIndex = tabController.animation!.value);
    });
  }

  @override
  Widget build(BuildContext context) => Provider.value(
        value: bloc,
        child: WillPopScope(
          onWillPop: () async {
            final goBack = await showConfirmationExitDialog(context);

            return goBack ?? false;
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: AppColors.lemon,
              foregroundColor: AppColors.darkGrey,
              title: GestureDetector(
                onLongPress: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => const EasterEggPage(),
                    ),
                  );
                },
                child: Text(
                  'Мемогенератор',
                  style: GoogleFonts.rubikBeastly(fontSize: 24),
                ),
              ),
              bottom: TabBar(
                controller: tabController,
                labelColor: AppColors.darkGrey,
                indicatorColor: AppColors.fuchsia,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Созданные'.toUpperCase()),
                  Tab(text: 'Шаблоны'.toUpperCase()),
                ],
              ),
            ),
            backgroundColor: Colors.white,
            floatingActionButton: tabIndex <= 0.5
                ? Transform.scale(
                    scale: 1 - tabIndex / 0.5,
                    child: const CreateMemeFab(),
                  )
                : Transform.scale(
                    scale: (tabIndex - 0.5) / 0.5,
                    child: const CreateTemplateFab(),
                  ),
            body: TabBarView(
              controller: tabController,
              children: const [
                SafeArea(child: CreatedMemesGrid()),
                SafeArea(child: TemplatesGrid()),
              ],
            ),
          ),
        ),
      );

  Future<bool?> showConfirmationExitDialog(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Точно хотите выйти?'),
          content: const Text('Мемы сами себя не сделают'),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
          actions: [
            AppButton(
              onTap: () => Navigator.of(context).pop(false),
              text: 'Остаться',
              color: AppColors.darkGrey,
            ),
            AppButton(
              onTap: () => Navigator.of(context).pop(true),
              text: 'Выйти',
            ),
          ],
        ),
      );

  @override
  void dispose() {
    bloc.dispose();
    tabController.dispose();
    super.dispose();
  }
}

class CreateMemeFab extends StatelessWidget {
  const CreateMemeFab({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);

    return FloatingActionButton.extended(
      onPressed: () async {
        final selectedMemePath = await bloc.selectMeme();
        if (selectedMemePath == null) {
          return;
        }
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => CreateMemePage(selectedMemePath: selectedMemePath),
          ),
        );
      },
      backgroundColor: AppColors.fuchsia,
      icon: const Icon(
        Icons.add,
        color: Colors.white,
      ),
      label: const Text('Мем'),
    );
  }
}

class CreateTemplateFab extends StatelessWidget {
  const CreateTemplateFab({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);

    return FloatingActionButton.extended(
      onPressed: () async {
        await bloc.addToTemplates();
      },
      backgroundColor: AppColors.fuchsia,
      icon: const Icon(
        Icons.add,
        color: Colors.white,
      ),
      label: const Text('Шаблон'),
    );
  }
}

class CreatedMemesGrid extends StatelessWidget {
  const CreatedMemesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);

    return StreamBuilder<List<MemeThumbnail>>(
      stream: bloc.observeMemes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final items = snapshot.requireData;

        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          children:
              items.map((item) => MemeGridItem(memeThumbnail: item)).toList(),
        );
      },
    );
  }
}

class TemplatesGrid extends StatelessWidget {
  const TemplatesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);

    return StreamBuilder<List<TemplateFull>>(
      stream: bloc.observeTemplates(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final templates = snapshot.requireData;

        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          children: templates
              .map((template) => TemplateGridItem(template: template))
              .toList(),
        );
      },
    );
  }
}

class TemplateGridItem extends StatelessWidget {
  const TemplateGridItem({
    required this.template,
    super.key,
  });

  final TemplateFull template;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    final imageFile = File(template.fullImagePath);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => CreateMemePage(
              selectedMemePath: template.fullImagePath,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            decoration:
                BoxDecoration(border: Border.all(color: AppColors.darkGrey)),
            child: imageFile.existsSync()
                ? Image.file(imageFile)
                : Text(template.id),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: DeleteButton(
              onDeleteAction: () => bloc.deleteTemplate(template.id),
              itemName: 'шаблон',
            ),
          ),
        ],
      ),
    );
  }
}

class MemeGridItem extends StatelessWidget {
  const MemeGridItem({
    required this.memeThumbnail,
    super.key,
  });

  final MemeThumbnail memeThumbnail;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    final imageFile = File(memeThumbnail.fullImageUrl);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (context) => CreateMemePage(id: memeThumbnail.memeId),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            decoration:
                BoxDecoration(border: Border.all(color: AppColors.darkGrey)),
            child: imageFile.existsSync()
                ? Image.file(imageFile)
                : Text(memeThumbnail.memeId),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: DeleteButton(
              onDeleteAction: () => bloc.deleteMeme(memeThumbnail.memeId),
              itemName: 'мем',
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    required this.onDeleteAction,
    required this.itemName,
    super.key,
  });

  final VoidCallback onDeleteAction;
  final String itemName;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async {
          final delete = await showConfirmationDeleteDialog(context) ?? false;
          if (delete) {
            onDeleteAction();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.darkGrey38,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
      );

  Future<bool?> showConfirmationDeleteDialog(BuildContext context) =>
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Удалить $itemName?'),
          content: Text('Выбранный $itemName будет удалён навсегда'),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
          actions: [
            AppButton(
              onTap: () => Navigator.of(context).pop(false),
              text: 'Отмена',
              color: AppColors.darkGrey,
            ),
            AppButton(
              onTap: () => Navigator.of(context).pop(true),
              text: 'Удалить',
            ),
          ],
        ),
      );
}
