import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memegenerator/app.dart';
import 'package:memegenerator/data/models/meme.dart';
import 'package:memegenerator/data/models/position.dart';
import 'package:memegenerator/data/models/text_with_position.dart';
import 'package:memegenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memegenerator/presentation/main/main_bloc.dart';
import 'package:memegenerator/presentation/main/main_page.dart';
import 'package:memegenerator/presentation/main/models/meme_thumbnail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../shared/test_helpers.dart';

void runTest2() {
  final textWithPosition = TextWithPosition(
    id: const Uuid().v4(),
    text: 'Мем-мем',
    position: const Position(top: 0, left: 0),
    fontSize: 30,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  final meme = Meme(id: const Uuid().v4(), texts: [textWithPosition]);
  final memeThumbnail = MemeThumbnail(
    memeId: meme.id,
    fullImageUrl:
        '${Directory(kApplicationDocumentsPath).absolute.path}${Platform.pathSeparator}${meme.id}.png',
  );
  const memeKey = 'meme_key';

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });
  testWidgets('module2', (tester) async {
    fancyPrint(
      'Run test module2',
      printType: PrintType.startEnd,
    );

    fancyPrint('Adding one meme to SharedPreferences for testing');
    SharedPreferences.setMockInitialValues(<String, Object>{
      memeKey: [jsonEncode(meme.toJson())],
    });

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    fancyPrint(
      'Проверяем, что метод observeMemes() внутри MainBloc имеет тип Stream<List<MemeThumbnail>>',
    );
    MainBloc().observeMemes().startWith([memeThumbnail]);

    fancyPrint(
      'We check that the observeMemes() method inside the Main Block is of type Stream<List<MemeThumbnail>>',
    );
    final memeGridItemFinder = find.byType(MemeGridItem);
    expect(
      memeGridItemFinder,
      findsOneWidget,
      reason:
          "mistake! It is impossible to find a single widget with the type 'MemeGridItem' on the MainPage page",
    );

    fancyPrint(
      'We check that the parameter in MemeGridItem is equal to the expected one',
    );
    final memeGridItem = tester.widget<MemeGridItem>(memeGridItemFinder);
    expect(
      memeGridItem.memeThumbnail,
      memeThumbnail,
      reason:
          'mistake! The memeThumbnail parameter in MemeGridItem is not equal to the expected one',
    );

    fancyPrint(
      'Переходим на страницу создания мема после нажатия на найденный MemeGridItem',
    );
    await tester.tap(memeGridItemFinder);
    await tester.pumpAndSettle();

    fancyPrint('We expect the Create Meme Page to open successfully');
    final createMemePageFinder = find.byType(CreateMemePage);

    expect(
      createMemePageFinder,
      findsOneWidget,
      reason:
          "mistake! It is impossible to find a single widget with the type 'CreateMemePage'",
    );

    fancyPrint(
      "We expect that the text of the meme is on the page '${textWithPosition.text}'",
    );
    final memeTextFinder = find.descendant(
      of: find.byType(MemeCanvasWidget),
      matching: find.text(textWithPosition.text),
    );
    expect(
      memeTextFinder,
      findsOneWidget,
      reason:
          "mistake! It is impossible to find a single widget with text '${textWithPosition.text}'",
    );

    fancyPrint(
      'SUCCESS! The test is passed!',
      printType: PrintType.startEnd,
    );
  });
}
