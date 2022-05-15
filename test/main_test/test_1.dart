import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memegenerator/app.dart';
import 'package:memegenerator/data/models/meme.dart';
import 'package:memegenerator/data/models/position.dart';
import 'package:memegenerator/data/models/template.dart';
import 'package:memegenerator/data/models/text_with_position.dart';
import 'package:memegenerator/presentation/main/main_page.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../shared/test_helpers.dart';

void runTest1() {
  final textWithPosition = TextWithPosition(
    id: const Uuid().v4(),
    text: 'Мем-мем',
    position: const Position(top: 0, left: 0),
    fontSize: 30,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  final meme = Meme(id: const Uuid().v4(), texts: [textWithPosition]);
  const memeKey = 'meme_key';

  final template = Template(id: const Uuid().v4(), imageUrl: 'pic.png');
  const templateKey = 'template_key';

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  testWidgets('module1', (tester) async {
    fancyPrint(
      'Запускаем тест к 1 заданию 12-го урока',
      printType: PrintType.startEnd,
    );

    fancyPrint(
      'Добавляем в SharedPreferences один мем и один шаблон для тестирования',
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      memeKey: [jsonEncode(meme.toJson())],
      templateKey: [jsonEncode(template.toJson())]
    });

    fancyPrint('Открываем App');

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    fancyPrint(
      'Проверяем удаление мемов',
      printType: PrintType.headline,
    );

    await checkOneThing<MemeGridItem>(
      tester: tester,
      keyInSP: memeKey,
      modelName: 'мем',
      widgetName: 'MemeGridItem',
    );

    const templatesText = 'ШАБЛОНЫ';
    fancyPrint("Ищем на странице вкладку с текстом '$templatesText'");
    final templatesButtonFinder = find.text(templatesText);
    expect(
      templatesButtonFinder,
      findsOneWidget,
      reason:
          "ОШИБКА! На странице MainPage невозможно найти виджет с текстом '$templatesText'",
    );

    fancyPrint("Нажимаем на вкладку с текстом '$templatesText'");
    await tester.tap(templatesButtonFinder);
    await tester.pumpAndSettle();

    fancyPrint(
      'Проверяем удаление шаблонов',
      printType: PrintType.headline,
    );
    await checkOneThing<TemplateGridItem>(
      tester: tester,
      keyInSP: templateKey,
      modelName: 'шаблон',
      widgetName: 'TemplateGridItem',
    );

    fancyPrint(
      'УСПЕХ! Тест пройден!',
      printType: PrintType.startEnd,
    );
  });
}

Future<void> checkOneThing<T>({
  required final WidgetTester tester,
  required final String keyInSP,
  required final String modelName,
  required final String widgetName,
}) async {
  fancyPrint('Ищем на странице MainPage единственный виджет $widgetName');
  final memeGridItemFinder = find.byType(T);
  expect(
    memeGridItemFinder,
    findsOneWidget,
    reason:
        'ОШИБКА! На странице MainPage невозможно найти единственный виджет с типом $widgetName',
  );

  fancyPrint('Ищем в найденном $widgetName кнопку, чтобы удалить $modelName');
  final deleteIconFinder = find.descendant(
    of: memeGridItemFinder,
    matching: find.byIcon(Icons.delete_outline),
  );
  expect(
    deleteIconFinder,
    findsOneWidget,
    reason:
        'ОШИБКА! У виджета $widgetName не найден потомок с иконкой Icons.delete_outline',
  );

  fancyPrint('Нажимаем на кнопку, чтобы удалить $modelName');
  await tester.tap(deleteIconFinder);
  await tester.pumpAndSettle();

  final dialogTitle = 'Удалить $modelName?';
  final dialogTitleFinder = find.text(dialogTitle);
  fancyPrint(
    "Ожидаем, что на экране появится диалог с заголовком '$dialogTitle'",
  );
  expect(
    dialogTitleFinder,
    findsOneWidget,
    reason: 'ОШИБКА! Диалог не открылся',
  );

  const cancelText = 'ОТМЕНА';
  final cancelButtonFinder = find.text(cancelText);
  fancyPrint("Ожидаем, что в диалоге есть кнопка с текстом '$cancelText'");
  expect(
    cancelButtonFinder,
    findsOneWidget,
    reason: "ОШИБКА! Невозможно найти кнопку с текстом '$cancelText'",
  );

  fancyPrint("Нажимаем на кнопку с текстом '$cancelText'");
  await tester.tap(cancelButtonFinder);
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  fancyPrint('Ищем на странице MainPage единственный виджет $widgetName');
  expect(
    memeGridItemFinder,
    findsOneWidget,
    reason:
        'ОШИБКА! На странице MainPage невозможно найти единственный виджет с типом $widgetName',
  );

  fancyPrint('Опять нажимаем на кнопку, чтобы удалить $modelName');
  await tester.tap(deleteIconFinder);
  await tester.pumpAndSettle();

  fancyPrint(
    "Ожидаем, что на экране появится диалог с заголовком '$dialogTitle'",
  );
  expect(
    dialogTitleFinder,
    findsOneWidget,
    reason: 'ОШИБКА! Диалог не открылся',
  );

  const deleteText = 'УДАЛИТЬ';
  final deleteButtonFinder = find.text(deleteText);
  fancyPrint("Ожидаем, что в диалоге есть кнопка с текстом '$deleteText'");
  expect(
    deleteButtonFinder,
    findsOneWidget,
    reason: "ОШИБКА! Невозможно найти кнопку с текстом '$deleteText'",
  );

  fancyPrint("Нажимаем на кнопку с текстом '$deleteText'");
  await tester.tap(deleteButtonFinder);
  await tester.pumpAndSettle();

  fancyPrint(
    'На странице MainPage не должно быть виджетов с типом $widgetName',
  );
  expect(
    memeGridItemFinder,
    findsNothing,
    reason:
        'ОШИБКА! На странице MainPage находятся виджеты $widgetName, хотя не должны',
  );

  fancyPrint('Проверяем, что в SharedPreferences $modelName удалён');

  expect(
    (await SharedPreferences.getInstance()).getStringList(keyInSP) ??
        <String>[],
    <String>[],
    reason: 'ОШИБКА! В SharedPreferences остался неудаленный $modelName',
  );
}
