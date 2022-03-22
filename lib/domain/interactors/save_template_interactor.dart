import 'package:memegenerator/data/models/template.dart';
import 'package:memegenerator/data/repositories/templates_repository.dart';
import 'package:memegenerator/domain/interactors/copy_unique_file_interactor.dart';
import 'package:uuid/uuid.dart';

class SaveTemplateInteractor {
  factory SaveTemplateInteractor.getInstance() =>
      _instance ??= SaveTemplateInteractor._internal();

  SaveTemplateInteractor._internal();

  static SaveTemplateInteractor? _instance;

  static const templatesPathName = "templates";

  Future<bool> saveTemplate({required final String imagePath}) async {
    final newImagePath =
        await CopyUniqueFileInteractor.getInstance().copyUniqueFile(
      directoryWithFiles: templatesPathName,
      filePath: imagePath,
    );
    final template = Template(
      id: const Uuid().v4(),
      imageUrl: newImagePath,
    );

    return TemplatesRepository.getInstance().addItemOrReplaceById(template);
  }
}
