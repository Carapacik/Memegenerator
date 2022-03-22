import 'package:memegenerator/data/models/meme.dart';
import 'package:memegenerator/data/models/text_with_position.dart';
import 'package:memegenerator/data/repositories/memes_repository.dart';
import 'package:memegenerator/domain/interactors/copy_unique_file_interactor.dart';
import 'package:memegenerator/domain/interactors/screenshot_interactor.dart';
import 'package:screenshot/screenshot.dart';

class SaveMemeInteractor {
  factory SaveMemeInteractor.getInstance() =>
      _instance ??= SaveMemeInteractor._internal();

  SaveMemeInteractor._internal();

  static SaveMemeInteractor? _instance;
  static const memesPathName = "memes";

  Future<bool> saveMeme({
    required final String id,
    required final List<TextWithPosition> textWithPositions,
    required final ScreenshotController screenshotController,
    final String? imagePath,
  }) async {
    late Meme meme;
    if (imagePath == null) {
      meme = Meme(id: id, texts: textWithPositions);
    } else {
      await ScreenshotInteractor.getInstance()
          .saveThumbnail(id, screenshotController.capture());
      final newImagePath =
          await CopyUniqueFileInteractor.getInstance().copyUniqueFile(
        directoryWithFiles: memesPathName,
        filePath: imagePath,
      );
      meme = Meme(
        id: id,
        texts: textWithPositions,
        memePath: newImagePath,
      );
    }
    return MemesRepository.getInstance().addItemOrReplaceById(meme);
  }
}
