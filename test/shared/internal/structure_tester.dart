import 'dart:io';

import 'extensions.dart';

class ElementNotExistsError extends Error {
  ElementNotExistsError(this.elementPath);

  final String elementPath;

  @override
  String toString() =>
      "ElementNotExistsError. No element found with path '$elementPath'";
}

class ElementHasWrongTypeError extends Error {
  ElementHasWrongTypeError(this.elementPath, this.desiredType, this.actualType);

  final String elementPath;
  final FileSystemEntityType desiredType;
  final FileSystemEntityType actualType;

  @override
  String toString() =>
      "ElementHasWrongTypeError. The element with path '$elementPath' has type $actualType but should be $desiredType";
}

void testStructure(final Map<String, FileSystemEntityType> structure) {
  final directory = Directory('');
  final allPaths = directory.listSync(recursive: true);

  final validatePath = (String path, FileSystemEntityType desiredType) {
    final entity = allPaths.firstWhereOrNull((element) => element.path == path);
    if (entity == null) {
      throw ElementNotExistsError(path);
    }
    final actualType = entity.statSync().type;
    if (actualType != desiredType) {
      throw ElementHasWrongTypeError(path, desiredType, actualType);
    }
  };

  structure.forEach(validatePath);
}
