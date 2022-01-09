import 'dart:io';

import 'package:collection/collection.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/models/text_with_position.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:path_provider/path_provider.dart';

class SaveMemeInteractor {
  static SaveMemeInteractor? _instance;

  factory SaveMemeInteractor.getInstance() => _instance ??= SaveMemeInteractor._internal();

  SaveMemeInteractor._internal();

  Future<bool> saveMeme({
    required final String id,
    required final List<TextWithPosition> textWithPositions,
    final String? imagePath,
  }) async {
    late Meme meme;
    if (imagePath == null) {
      meme = Meme(id: id, texts: textWithPositions);
    } else {
      final newImagePath = await createNewFile(imagePath);
      meme = Meme(
        id: id,
        texts: textWithPositions,
        memePath: newImagePath,
      );
    }
    return MemesRepository.getInstance().addToMemes(meme);
  }

  Future<String> createNewFile(final String imagePath) async {
    // Работа с папками
    final docsPath = await getApplicationDocumentsDirectory();
    final memePath = "${docsPath.absolute.path}${Platform.pathSeparator}memes";
    final memesDirectory = Directory(memePath);
    await memesDirectory.create(recursive: true);
    final currentFiles = memesDirectory.listSync();

    // Работа с именем файла
    final imageName = _getFileNameByPath(imagePath);
    final oldFileWithTheSameName = currentFiles.firstWhereOrNull(
      (element) {
        return _getFileNameByPath(element.path) == imageName && element is File;
      },
    );
    final newImagePath = "$memePath${Platform.pathSeparator}$imageName";
    final tempFile = File(imagePath);

    if (oldFileWithTheSameName == null) {
      await tempFile.copy(newImagePath);
      return newImagePath;
    }
    final oldFileLength = await (oldFileWithTheSameName as File).length();
    final newFileLength = await tempFile.length();
    if (oldFileLength == newFileLength) {
      return newImagePath;
    }
    return _createFileForSameNameButDifferentLength(
      imageName,
      tempFile,
      newImagePath,
      memePath,
    );
  }

  Future<String> _createFileForSameNameButDifferentLength(
    final String imageName,
    final File tempFile,
    final String newImagePath,
    final String memePath,
  ) async {
    final indexOfLastDot = imageName.lastIndexOf(".");
    if (indexOfLastDot == -1) {
      await tempFile.copy(newImagePath);
      return newImagePath;
    }

    final ext = imageName.substring(indexOfLastDot);
    final imageNameWithoutExt = imageName.substring(0, indexOfLastDot);
    final indexOfLastUnderscore = imageNameWithoutExt.lastIndexOf("_");

    if (indexOfLastUnderscore == -1) {
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}${imageNameWithoutExt}_1$ext";
      await tempFile.copy(correctedNewImagePath);
      return correctedNewImagePath;
    } else {
      final suffixNumberString = imageNameWithoutExt.substring(indexOfLastUnderscore + 1);
      final suffixNumber = int.tryParse(suffixNumberString);
      if (suffixNumber == null) {
        final correctedNewImagePath =
            "$memePath${Platform.pathSeparator}${imageNameWithoutExt}_1$ext";
        await tempFile.copy(correctedNewImagePath);
        return correctedNewImagePath;
      } else {
        final imageNameWithoutSuffix = imageNameWithoutExt.substring(0, indexOfLastUnderscore + 1);
        final correctedNewImagePath =
            "$memePath${Platform.pathSeparator}$imageNameWithoutSuffix${suffixNumber + 1}";
        await tempFile.copy(correctedNewImagePath);
        return correctedNewImagePath;
      }
    }
  }

  String _getFileNameByPath(String path) => path.split(Platform.pathSeparator).last;
}