import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:memegenerator/data/models/meme.dart';
import 'package:memegenerator/data/models/position.dart';
import 'package:memegenerator/data/models/text_with_position.dart';
import 'package:memegenerator/data/repositories/memes_repository.dart';
import 'package:memegenerator/domain/interactors/save_meme_interactor.dart';
import 'package:memegenerator/domain/interactors/screenshot_interactor.dart';
import 'package:memegenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memegenerator/presentation/create_meme/models/meme_text_offset.dart';
import 'package:memegenerator/presentation/create_meme/models/meme_text_with_offset.dart';
import 'package:memegenerator/presentation/create_meme/models/meme_text_with_selection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';

class CreateMemeBloc {
  CreateMemeBloc({
    final String? id,
    final String? selectedMemePath,
  }) : id = id ?? const Uuid().v4() {
    memePathSubject.add(selectedMemePath);
    _subscribeToNewMemTextOffset();
    unawaited(_subscribeToExistentMeme());
  }

  final String id;

  final memeTextsSubject = BehaviorSubject<List<MemeText>>.seeded([]);
  final selectedMemeTextsSubject = BehaviorSubject<MemeText?>.seeded(null);
  final memeTextOffsetsSubject =
      BehaviorSubject<List<MemeTextOffset>>.seeded([]);
  final newMemeTextOffsetSubject =
      BehaviorSubject<MemeTextOffset?>.seeded(null);
  final memePathSubject = BehaviorSubject<String?>.seeded(null);
  final screenshotControllerSubject =
      BehaviorSubject<ScreenshotController>.seeded(ScreenshotController());

  StreamSubscription<MemeTextOffset?>? newMemeTextOffsetSubscription;
  StreamSubscription<bool>? saveMemeSubscription;
  StreamSubscription<Meme?>? existentMemeSubscription;
  StreamSubscription<void>? shareMemeSubscription;

  Stream<String?> observeMemePath() => memePathSubject.distinct();

  Stream<List<MemeText>> observeMemeTexts() => memeTextsSubject.distinct(
        (prev, next) => const ListEquality<MemeText>().equals(prev, next),
      );

  Stream<List<MemeTextWithOffset>> observeMemeTextsWithOffsets() =>
      Rx.combineLatest2<List<MemeText>, List<MemeTextOffset>,
          List<MemeTextWithOffset>>(
        observeMemeTexts(),
        memeTextOffsetsSubject.distinct(),
        (memeTexts, memeTextOffsets) => memeTexts.map((memeText) {
          final memeTextOffset = memeTextOffsets
              .firstWhereOrNull((elem) => elem.id == memeText.id);

          return MemeTextWithOffset(
            offset: memeTextOffset?.offset,
            memeText: memeText,
          );
        }).toList(),
      ).distinct(
        (prev, next) =>
            const ListEquality<MemeTextWithOffset>().equals(prev, next),
      );

  Stream<MemeText?> observeSelectedMemeTexts() =>
      selectedMemeTextsSubject.distinct();

  Stream<ScreenshotController> observeScreenshotController() =>
      screenshotControllerSubject.distinct();

  Stream<List<MemeTextWithSelection>> observeSelectedMemeTextsWithSelection() =>
      Rx.combineLatest2<List<MemeText>, MemeText?, List<MemeTextWithSelection>>(
        observeMemeTexts(),
        observeSelectedMemeTexts(),
        (memeTexts, selectedMemeText) => memeTexts
            .map(
              (memeText) => MemeTextWithSelection(
                memeText: memeText,
                selected: memeText.id == selectedMemeText?.id,
              ),
            )
            .toList(),
      );

  Future<bool> isAllSaved() async {
    final savedMeme = await MemesRepository.getInstance().getItemById(id);
    if (savedMeme == null) {
      return false;
    }
    final savedMemeTexts =
        savedMeme.texts.map(MemeText.createFromTextWithPosition).toList();
    final savedMemeTextsOffsets = savedMeme.texts
        .map(
          (textWithPosition) => MemeTextOffset(
            id: textWithPosition.id,
            offset: Offset(
              textWithPosition.position.left,
              textWithPosition.position.top,
            ),
          ),
        )
        .toList();

    // Сравнение списков вне зависимости от положения элементов
    return const DeepCollectionEquality.unordered()
            .equals(savedMemeTexts, memeTextsSubject.value) &&
        const DeepCollectionEquality.unordered()
            .equals(savedMemeTextsOffsets, memeTextOffsetsSubject.value);
  }

  Future<void> shareMeme() async {
    await shareMemeSubscription?.cancel();
    shareMemeSubscription = ScreenshotInteractor.getInstance()
        .shareScreenshot(screenshotControllerSubject.value.capture())
        .asStream()
        .listen(
      (event) {},
      // ignore: inference_failure_on_untyped_parameter
      onError: (error, stackTrace) {
        if (kDebugMode) {
          print('Error in shareMemeSubscription: $error, $stackTrace');
        }
      },
    );
  }

  void changeFontSetting(
    final String textId,
    final Color color,
    final double fontSize,
    final FontWeight fontWeight,
  ) {
    final copiedList = [...memeTextsSubject.value];
    final oldMemeText =
        copiedList.firstWhereOrNull((element) => element.id == textId);
    if (oldMemeText == null) {
      return;
    }
    copiedList
      ..remove(oldMemeText)
      ..add(
        oldMemeText.copyWithChangedFontSetting(color, fontSize, fontWeight),
      );
    memeTextsSubject.add(copiedList);
  }

  void deselectMemeText() {
    selectedMemeTextsSubject.add(null);
  }

  void deleteMemeText(final String id) {
    final updatedMemeTexts = [...memeTextsSubject.value]
      ..removeWhere((element) => element.id == id);
    memeTextsSubject.add(updatedMemeTexts);
  }

  Future<void> saveMeme() async {
    final memeTexts = memeTextsSubject.value;
    final memeTextOffsets = memeTextOffsetsSubject.value;

    final textWithPositions = memeTexts.map((memeText) {
      final memeTextPosition = memeTextOffsets.firstWhereOrNull(
        (memeTextOffset) => memeTextOffset.id == memeText.id,
      );

      final position = Position(
        top: memeTextPosition?.offset.dy ?? 0,
        left: memeTextPosition?.offset.dx ?? 0,
      );

      return TextWithPosition(
        id: memeText.id,
        text: memeText.text,
        position: position,
        fontSize: memeText.fontSize,
        color: memeText.color,
        fontWeight: memeText.fontWeight,
      );
    }).toList();

    saveMemeSubscription = SaveMemeInteractor.getInstance()
        .saveMeme(
          id: id,
          textWithPositions: textWithPositions,
          imagePath: memePathSubject.value,
          screenshotController: screenshotControllerSubject.value,
        )
        .asStream()
        .listen(
      (event) {
        if (kDebugMode) {
          print('Meme saved: $event');
        }
      },
      // ignore: inference_failure_on_untyped_parameter
      onError: (error, stackTrace) {
        if (kDebugMode) {
          print('Error in saveMemeSubscription: $error, $stackTrace');
        }
      },
    );
  }

  void changeMemeTextOffset(final String id, final Offset offset) {
    newMemeTextOffsetSubject.add(MemeTextOffset(id: id, offset: offset));
  }

  void addNewText() {
    final newMemeText = MemeText.create();
    memeTextsSubject.add([...memeTextsSubject.value, newMemeText]);
    selectedMemeTextsSubject.add(newMemeText);
  }

  void changeMemeText(final String id, final String text) {
    final copiedList = [...memeTextsSubject.value];
    final index = copiedList.indexWhere((element) => element.id == id);
    if (index == -1) {
      return;
    }
    final oldMemeText = copiedList[index];
    copiedList[index] = oldMemeText.copyWithChangedText(text);
    memeTextsSubject.add(copiedList);
  }

  void selectMemeText(final String id) {
    final foundMemeText =
        memeTextsSubject.value.firstWhereOrNull((element) => element.id == id);
    selectedMemeTextsSubject.add(foundMemeText);
  }

  void _changeMemeTextOffsetInternal(final MemeTextOffset newMemeTextOffset) {
    final copiedMemeTextOffsets = [...memeTextOffsetsSubject.value];
    final currentMemeTextOffset = memeTextOffsetsSubject.value.firstWhereOrNull(
      (memeTextOffset) => memeTextOffset.id == newMemeTextOffset.id,
    );
    if (currentMemeTextOffset != null) {
      copiedMemeTextOffsets.remove(currentMemeTextOffset);
    }
    copiedMemeTextOffsets.add(newMemeTextOffset);
    memeTextOffsetsSubject.add(copiedMemeTextOffsets);
  }

  void _subscribeToNewMemTextOffset() {
    newMemeTextOffsetSubscription = newMemeTextOffsetSubject
        .debounceTime(const Duration(milliseconds: 300))
        .listen(
      (newMemeTextOffset) {
        if (newMemeTextOffset != null) {
          _changeMemeTextOffsetInternal(newMemeTextOffset);
        }
      },
      // ignore: inference_failure_on_untyped_parameter
      onError: (error, stackTrace) {
        if (kDebugMode) {
          print('Error in newMemeTextOffsetSubscription: $error, $stackTrace');
        }
      },
    );
  }

  Future<void> _subscribeToExistentMeme() async {
    existentMemeSubscription =
        MemesRepository.getInstance().getItemById(id).asStream().listen(
      (meme) async {
        if (meme == null) {
          return;
        } else {
          final memeTexts =
              meme.texts.map(MemeText.createFromTextWithPosition).toList();
          final memeTextsOffsets = meme.texts
              .map(
                (textWithPosition) => MemeTextOffset(
                  id: textWithPosition.id,
                  offset: Offset(
                    textWithPosition.position.left,
                    textWithPosition.position.top,
                  ),
                ),
              )
              .toList();
          memeTextsSubject.add(memeTexts);
          memeTextOffsetsSubject.add(memeTextsOffsets);
          if (meme.memePath != null) {
            await getApplicationDocumentsDirectory().then((dir) {
              final onlyImagePath =
                  meme.memePath!.split(Platform.pathSeparator).last;
              final fullImagePath =
                  '${dir.absolute.path}${Platform.pathSeparator}${SaveMemeInteractor.memesPathName}${Platform.pathSeparator}$onlyImagePath';
              memePathSubject.add(fullImagePath);
            });
          }
        }
      },
      // ignore: inference_failure_on_untyped_parameter
      onError: (error, stackTrace) {
        if (kDebugMode) {
          print('Error in existentMemeSubscription: $error, $stackTrace');
        }
      },
    );
  }

  Future<void> dispose() async {
    await memeTextsSubject.close();
    await selectedMemeTextsSubject.close();
    await memeTextOffsetsSubject.close();
    await newMemeTextOffsetSubject.close();
    await memePathSubject.close();
    await screenshotControllerSubject.close();

    await newMemeTextOffsetSubscription?.cancel();
    await saveMemeSubscription?.cancel();
    await existentMemeSubscription?.cancel();
    await shareMemeSubscription?.cancel();
  }
}
