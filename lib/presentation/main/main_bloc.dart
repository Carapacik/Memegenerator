import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/models/template.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:memogenerator/data/repositories/templates_repository.dart';
import 'package:memogenerator/domain/interactors/save_template_interactor.dart';
import 'package:memogenerator/presentation/main/models/meme_thumbnail.dart';
import 'package:memogenerator/presentation/main/models/template_full.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class MainBloc {
  Stream<List<MemeThumbnail>> observeMemes() {
    return Rx.combineLatest2<List<Meme>, Directory, List<MemeThumbnail>>(
      MemesRepository.getInstance().observeItems(),
      getApplicationDocumentsDirectory().asStream(),
      (memes, docs) {
        return memes.map(
          (meme) {
            final fullImageUrl =
                "${docs.absolute.path}${Platform.pathSeparator}${meme.id}.png";
            return MemeThumbnail(memeId: meme.id, fullImageUrl: fullImageUrl);
          },
        ).toList();
      },
    );
  }

  Stream<List<TemplateFull>> observeTemplates() {
    return Rx.combineLatest2<List<Template>, Directory, List<TemplateFull>>(
      TemplatesRepository.getInstance().observeItems(),
      getApplicationDocumentsDirectory().asStream(),
      (templates, docs) {
        return templates.map(
          (template) {
            final fullImagePath =
                "${docs.absolute.path}${Platform.pathSeparator}${SaveTemplateInteractor.templatesPathName}${Platform.pathSeparator}${template.imageUrl}";
            return TemplateFull(id: template.id, fullImagePath: fullImagePath);
          },
        ).toList();
      },
    );
  }

  Future<String?> selectMeme() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    final imagePath = file?.path;
    if (imagePath != null) {
      await SaveTemplateInteractor.getInstance()
          .saveTemplate(imagePath: imagePath);
    }
    return imagePath;
  }

  Future<void> addToTemplates() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    final imagePath = file?.path;
    if (imagePath != null) {
      await SaveTemplateInteractor.getInstance()
          .saveTemplate(imagePath: imagePath);
    }
  }

  void deleteMeme(final String memeId) {
    MemesRepository.getInstance().removeFromItemsById(memeId);
  }

  void deleteTemplate(final String templateId) {
    TemplatesRepository.getInstance().removeFromItemsById(templateId);
  }

  void dispose() {}
}
