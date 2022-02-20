import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';

class CopyUniqueFileInteractor {
  static CopyUniqueFileInteractor? _instance;

  factory CopyUniqueFileInteractor.getInstance() =>
      _instance ??= CopyUniqueFileInteractor._internal();

  CopyUniqueFileInteractor._internal();

  Future<String> copyUniqueFile({
    required final String directoryWithFiles,
    required final String filePath,
  }) async {
    // Работа с папками
    final docsPath = await getApplicationDocumentsDirectory();
    final memePath =
        "${docsPath.absolute.path}${Platform.pathSeparator}$directoryWithFiles";
    final memesDirectory = Directory(memePath);
    await memesDirectory.create(recursive: true);
    final currentFiles = memesDirectory.listSync();

    // Работа с именем файла
    final imageName = _getFileNameByPath(filePath);
    final oldFileWithTheSameName = currentFiles.firstWhereOrNull(
      (element) {
        return _getFileNameByPath(element.path) == imageName && element is File;
      },
    );
    final newImagePath = "$memePath${Platform.pathSeparator}$imageName";
    final tempFile = File(filePath);

    if (oldFileWithTheSameName == null) {
      // Файлов с таким название нет. Сохраняем файл в документы
      await tempFile.copy(newImagePath);
      return imageName;
    }
    final oldFileLength = await (oldFileWithTheSameName as File).length();
    final newFileLength = await tempFile.length();
    if (oldFileLength == newFileLength) {
      // Такой файл уже существует. Не сохраняем его заново
      return imageName;
    }
    final indexOfLastDot = imageName.lastIndexOf(".");
    if (indexOfLastDot == -1) {
      // У файла нет расширения. Сохраняем файл в документы
      await tempFile.copy(newImagePath);
      return imageName;
    }
    final ext = imageName.substring(indexOfLastDot);
    final imageNameWithoutExt = imageName.substring(0, indexOfLastDot);
    final indexOfLastUnderscore = imageNameWithoutExt.lastIndexOf("_");

    if (indexOfLastUnderscore == -1) {
      // Файл с таким названием, но с другим размером есть.
      // Сохраняем файл в документы и добавляем суффикс '_1'
      final newImageName = "${imageNameWithoutExt}_1$ext";
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}$newImageName";
      await tempFile.copy(correctedNewImagePath);
      return newImageName;
    }
    final suffixNumberString =
        imageNameWithoutExt.substring(indexOfLastUnderscore + 1);
    final suffixNumber = int.tryParse(suffixNumberString);
    if (suffixNumber == null) {
      // Файл с таким названием, но с другим размером есть.
      // Суффикс не является числом
      // Сохраняем файл в документы и добавляем суффикс '_1'
      final newImageName = "${imageNameWithoutExt}_1$ext";
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}$newImageName";
      await tempFile.copy(correctedNewImagePath);
      return newImageName;
    }

    // Файл с таким названием, но с другим размером есть.
    // Увеличиваем число в суффиксе и сохраняем файл в документы
    final imageNameWithoutSuffix =
        imageNameWithoutExt.substring(0, indexOfLastUnderscore);

    final newImageName = "${imageNameWithoutSuffix}_${suffixNumber + 1}$ext";
    final correctedNewImagePath =
        "$memePath${Platform.pathSeparator}newImageName";
    await tempFile.copy(correctedNewImagePath);
    return newImageName;
  }

  String _getFileNameByPath(String path) =>
      path.split(Platform.pathSeparator).last;
}
