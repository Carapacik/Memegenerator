import 'dart:io';

import 'extensions.dart';

class ElementNotExistsError extends Error {
  ElementNotExistsError(this.elementPath);

  final String elementPath;

  @override
  String toString() {
    return "ElementNotExistsError. No element found with path '$elementPath'";
  }
}

class ElementHasWrongTypeError extends Error {
  ElementHasWrongTypeError(this.elementPath, this.desiredType, this.actualType);

  final String elementPath;
  final FileSystemEntityType desiredType;
  final FileSystemEntityType actualType;

  @override
  String toString() {
    return "ElementHasWrongTypeError. The element with path '$elementPath' has type $actualType but should be $desiredType";
  }
}

void testStructure(final Map<String, FileSystemEntityType> structure) {
  var directory = Directory("");
  var allPaths = directory.listSync(recursive: true);

  var validatePath = (String path, FileSystemEntityType desiredType) {
    final FileSystemEntity? entity =
        allPaths.firstWhereOrNull((element) => element.path == path);
    if (entity == null) {
      throw ElementNotExistsError(path);
    }
    final FileSystemEntityType actualType = entity.statSync().type;
    if (actualType != desiredType) {
      throw ElementHasWrongTypeError(path, desiredType, actualType);
    }
  };

  structure.forEach((key, value) {
    validatePath(key, value);
  });
}
