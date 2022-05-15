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
  testWidgets('module3', (tester) async {
    fancyPrint(
      'Запускаем тест к 3 заданию 12-го урока',
      printType: PrintType.startEnd,
    );

    fancyPrint('Добавляем в SharedPreferences один мем для тестирования');
    SharedPreferences.setMockInitialValues(<String, Object>{
      memeKey: [jsonEncode(meme.toJson())]
    });

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    fancyPrint(
      'Проверяем, что метод observeMemes() внутри MainBloc имеет тип Stream<List<MemeThumbnail>>',
    );
    MainBloc().observeMemes().startWith([memeThumbnail]);

    fancyPrint('Ищем на странице MainPage единственный виджет MemeGridItem');
    final memeGridItemFinder = find.byType(MemeGridItem);
    expect(
      memeGridItemFinder,
      findsOneWidget,
      reason:
          "ОШИБКА! На странице MainPage невозможно найти единственный виджет с типом 'MemeGridItem'",
    );

    fancyPrint('Проверяем, что параметр в MemeGridItem равен ожидаемому');
    final memeGridItem = tester.widget<MemeGridItem>(memeGridItemFinder);
    expect(
      memeGridItem.memeThumbnail,
      memeThumbnail,
      reason:
          'ОШИБКА! Параметр memeThumbnail в MemeGridItem не равен ожидаемому',
    );

    fancyPrint(
      'Переходим на страницу создания мема после нажатия на найденный MemeGridItem',
    );
    await tester.tap(memeGridItemFinder);
    await tester.pumpAndSettle();

    fancyPrint('Ожидаем, что страница CreateMemePage открылась успешно');
    final createMemePageFinder = find.byType(CreateMemePage);

    expect(
      createMemePageFinder,
      findsOneWidget,
      reason:
          "ОШИБКА! Невозможно найти единственный виджет с типом 'CreateMemePage'",
    );

    fancyPrint(
      "Ожидаем, что на странице находится текст мема '${textWithPosition.text}'",
    );
    final memeTextFinder = find.descendant(
      of: find.byType(MemeCanvasWidget),
      matching: find.text(textWithPosition.text),
    );
    expect(
      memeTextFinder,
      findsOneWidget,
      reason:
          "ОШИБКА! Невозможно найти единственный виджет с текстом '${textWithPosition.text}'",
    );

    fancyPrint(
      'УСПЕХ! Тест пройден!',
      printType: PrintType.startEnd,
    );
  });
}
