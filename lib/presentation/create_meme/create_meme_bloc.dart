import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/models/position.dart';
import 'package:memogenerator/data/models/text_with_position.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:memogenerator/domain/interactors/save_meme_interactor.dart';
import 'package:memogenerator/domain/interactors/screenshot_interactor.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_offset.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_offset.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_selection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';

class CreateMemeBloc {
  final memeTextsSubject = BehaviorSubject<List<MemeText>>.seeded([]);
  final selectedMemeTextsSubject = BehaviorSubject<MemeText?>.seeded(null);
  final memeTextOffsetsSubject = BehaviorSubject<List<MemeTextOffset>>.seeded([]);
  final newMemeTextOffsetSubject = BehaviorSubject<MemeTextOffset?>.seeded(null);
  final memePathSubject = BehaviorSubject<String?>.seeded(null);
  final screenshotControllerSubject =
      BehaviorSubject<ScreenshotController>.seeded(ScreenshotController());

  final String id;

  CreateMemeBloc({
    final String? id,
    final String? selectedMemePath,
  }) : id = id ?? const Uuid().v4() {
    memePathSubject.add(selectedMemePath);
    _subscribeToNewMemTextOffset();
    _subscribeToExistentMeme();
  }

  StreamSubscription<MemeTextOffset?>? newMemeTextOffsetSubscription;
  StreamSubscription<bool>? saveMemeSubscription;
  StreamSubscription<Meme?>? existentMemeSubscription;
  StreamSubscription<void>? shareMemeSubscription;

  Stream<String?> observeMemePath() => memePathSubject.distinct();

  Stream<List<MemeText>> observeMemeTexts() =>
      memeTextsSubject.distinct((prev, next) => const ListEquality().equals(prev, next));

  Stream<List<MemeTextWithOffset>> observeMemeTextsWithOffsets() {
    return Rx.combineLatest2<List<MemeText>, List<MemeTextOffset>, List<MemeTextWithOffset>>(
        observeMemeTexts(), memeTextOffsetsSubject.distinct(), (memeTexts, memeTextOffsets) {
      return memeTexts.map((memeText) {
        final memeTextOffset = memeTextOffsets.firstWhereOrNull((elem) {
          return elem.id == memeText.id;
        });
        return MemeTextWithOffset(
          id: memeText.id,
          text: memeText.text,
          offset: memeTextOffset?.offset,
        );
      }).toList();
    }).distinct((prev, next) => const ListEquality().equals(prev, next));
  }

  Stream<MemeText?> observeSelectedMemeTexts() => selectedMemeTextsSubject.distinct();

  Stream<ScreenshotController> observeScreenshotController() =>
      screenshotControllerSubject.distinct();

  Stream<List<MemeTextWithSelection>> observeSelectedMemeTextsWithSelection() {
    return Rx.combineLatest2<List<MemeText>, MemeText?, List<MemeTextWithSelection>>(
      observeMemeTexts(),
      observeSelectedMemeTexts(),
      (memeTexts, selectedMemeText) {
        return memeTexts.map((memeText) {
          return MemeTextWithSelection(
            memeText: memeText,
            selected: memeText.id == selectedMemeText?.id,
          );
        }).toList();
      },
    );
  }

  void _subscribeToExistentMeme() {
    existentMemeSubscription = MemesRepository.getInstance().getMeme(id).asStream().listen(
      (meme) {
        if (meme == null) {
          return;
        } else {
          final memeTexts = meme.texts
              .map(
                (textWithPosition) =>
                    MemeText(id: textWithPosition.id, text: textWithPosition.text),
              )
              .toList();
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
            getApplicationDocumentsDirectory().then((dir) {
              final onlyImagePath = meme.memePath!.split(Platform.pathSeparator).last;
              final fullImagePath =
                  "${dir.absolute.path}${Platform.pathSeparator}${SaveMemeInteractor.memesPathName}" +
                      "${Platform.pathSeparator}$onlyImagePath";
              memePathSubject.add(fullImagePath);
            });
          }
        }
      },
      onError: (error, stackTrace) =>
          print("Error in existentMemeSubscription: $error, $stackTrace"),
    );
  }

  void shareMeme() {
    shareMemeSubscription?.cancel();
    shareMemeSubscription = ScreenshotInteractor.getInstance()
        .shareScreenshot(screenshotControllerSubject.value.capture())
        .asStream()
        .listen(
          (event) {},
          onError: (error, stackTrace) =>
              print("Error in existentMemeSubscription: $error, $stackTrace"),
        );
  }

  void saveMeme() {
    final memeTexts = memeTextsSubject.value;
    final memeTextOffsets = memeTextOffsetsSubject.value;

    final textWithPositions = memeTexts.map((memeText) {
      final memeTextPosition = memeTextOffsets.firstWhereOrNull((memeTextOffset) {
        return memeTextOffset.id == memeText.id;
      });

      final position = Position(
        top: memeTextPosition?.offset.dy ?? 0,
        left: memeTextPosition?.offset.dx ?? 0,
      );
      return TextWithPosition(id: memeText.id, text: memeText.text, position: position);
    }).toList();

    saveMemeSubscription = SaveMemeInteractor.getInstance()
        .saveMeme(
          id: id,
          textWithPositions: textWithPositions,
          imagePath: memePathSubject.value,
        )
        .asStream()
        .listen(
      (event) {
        print("Meme saved: $event");
      },
      onError: (error, stackTrace) => print("Error in saveMemeSubscription: $error, $stackTrace"),
    );
  }

  void _subscribeToNewMemTextOffset() {
    newMemeTextOffsetSubscription =
        newMemeTextOffsetSubject.debounceTime(const Duration(milliseconds: 300)).listen(
      (newMemeTextOffset) {
        if (newMemeTextOffset != null) {
          _changeMemeTextOffsetInternal(newMemeTextOffset);
        }
      },
      onError: (error, stackTrace) =>
          print("Error in newMemeTextOffsetSubscription: $error, $stackTrace"),
    );
  }

  void changeMemeTextOffset(final String id, final Offset offset) {
    newMemeTextOffsetSubject.add(MemeTextOffset(id: id, offset: offset));
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
    copiedList.removeAt(index);
    copiedList.insert(index, MemeText(id: id, text: text));
    memeTextsSubject.add(copiedList);
  }

  void selectMemeText(final String id) {
    final foundMemeText = memeTextsSubject.value.firstWhereOrNull((element) => element.id == id);
    selectedMemeTextsSubject.add(foundMemeText);
  }

  void deselectMemeText() {
    selectedMemeTextsSubject.add(null);
  }

  void dispose() {
    memeTextsSubject.close();
    selectedMemeTextsSubject.close();
    memeTextOffsetsSubject.close();
    newMemeTextOffsetSubject.close();
    memePathSubject.close();
    screenshotControllerSubject.close();

    newMemeTextOffsetSubscription?.cancel();
    saveMemeSubscription?.cancel();
    existentMemeSubscription?.cancel();
    shareMemeSubscription?.cancel();
  }
}
