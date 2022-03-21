import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ScreenshotInteractor {
  factory ScreenshotInteractor.getInstance() =>
      _instance ??= ScreenshotInteractor._internal();

  ScreenshotInteractor._internal();

  static ScreenshotInteractor? _instance;

  Future<void> shareScreenshot(final Future<Uint8List?> capture) async {
    final image = await capture;
    if (image == null) {
      return;
    }
    final tempDocs = await getTemporaryDirectory();
    final imageFile = File(
      "${tempDocs.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}.png",
    );
    await imageFile.create();
    await imageFile.writeAsBytes(image);
    await Share.shareFiles([imageFile.path]);
  }

  Future<void> saveThumbnail(
    final String memeId,
    final Future<Uint8List?> capture,
  ) async {
    final image = await capture;
    if (image == null) {
      return;
    }
    final tempDocs = await getApplicationDocumentsDirectory();
    final imageFile = File(
      "${tempDocs.path}${Platform.pathSeparator}$memeId.png",
    );
    await imageFile.create();
    await imageFile.writeAsBytes(image);
    await FileImage(imageFile).evict();
  }
}
