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
      'Run test module1',
      printType: PrintType.startEnd,
    );

    fancyPrint(
      'Adding one meme and one template to SharedPreferences for testing',
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      memeKey: [jsonEncode(meme.toJson())],
      templateKey: [jsonEncode(template.toJson())],
    });

    fancyPrint('Opening the App');

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    fancyPrint(
      'Checking the removal of memes',
      printType: PrintType.headline,
    );

    await checkOneThing<MemeGridItem>(
      tester: tester,
      keyInSP: memeKey,
      modelName: 'мем',
      widgetName: 'MemeGridItem',
    );

    const templatesText = 'ШАБЛОНЫ';
    fancyPrint(
      "We are looking for a tab with text on the page '$templatesText'",
    );
    final templatesButtonFinder = find.text(templatesText);
    expect(
      templatesButtonFinder,
      findsOneWidget,
      reason:
          "mistake! It is impossible to find a widget with text on the MainPage page '$templatesText'",
    );

    fancyPrint("Click on the tab with the text '$templatesText'");
    await tester.tap(templatesButtonFinder);
    await tester.pumpAndSettle();

    fancyPrint(
      'Checking the deletion of templates',
      printType: PrintType.headline,
    );
    await checkOneThing<TemplateGridItem>(
      tester: tester,
      keyInSP: templateKey,
      modelName: 'шаблон',
      widgetName: 'TemplateGridItem',
    );

    fancyPrint(
      'SUCCESS! The test is passed!',
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
  fancyPrint(
    'We are looking for the only widget on the MainPage page $widgetName',
  );
  final memeGridItemFinder = find.byType(T);
  expect(
    memeGridItemFinder,
    findsOneWidget,
    reason:
        'mistake! It is impossible to find a single widget with the type on the MainPage page $widgetName',
  );

  fancyPrint(
    'We search in the found $widgetName the button to delete $modelName',
  );
  final deleteIconFinder = find.descendant(
    of: memeGridItemFinder,
    matching: find.byIcon(Icons.delete_outline),
  );
  expect(
    deleteIconFinder,
    findsOneWidget,
    reason:
        'mistake! The widget has $widgetName the descendant with the icon was not found Icons.delete_outline',
  );

  fancyPrint('Click on the button to delete $modelName');
  await tester.tap(deleteIconFinder);
  await tester.pumpAndSettle();

  final dialogTitle = 'Удалить $modelName?';
  final dialogTitleFinder = find.text(dialogTitle);
  fancyPrint(
    "We expect that a dialog with the title will appear on the screen '$dialogTitle'",
  );
  expect(
    dialogTitleFinder,
    findsOneWidget,
    reason: 'mistake! The dialog did not open',
  );

  const cancelText = 'ОТМЕНА';
  final cancelButtonFinder = find.text(cancelText);
  fancyPrint(
    "We expect that there is a button with text in the dialog '$cancelText'",
  );
  expect(
    cancelButtonFinder,
    findsOneWidget,
    reason: "mistake! The button with the text cannot be found '$cancelText'",
  );

  fancyPrint("Click on the button with the text '$cancelText'");
  await tester.tap(cancelButtonFinder);
  await tester.pumpAndSettle(const Duration(milliseconds: 200));

  fancyPrint(
    'We are looking for the only widget on the MainPage page $widgetName',
  );
  expect(
    memeGridItemFinder,
    findsOneWidget,
    reason:
        'mistake! It is impossible to find a single widget with the type on the MainPage page $widgetName',
  );

  fancyPrint('Click on the button again to delete $modelName');
  await tester.tap(deleteIconFinder);
  await tester.pumpAndSettle();

  fancyPrint(
    "We expect that a dialog with the title will appear on the screen '$dialogTitle'",
  );
  expect(
    dialogTitleFinder,
    findsOneWidget,
    reason: 'mistake! The dialog did not open',
  );

  const deleteText = 'УДАЛИТЬ';
  final deleteButtonFinder = find.text(deleteText);
  fancyPrint(
    "We expect that there is a button with text in the dialog '$deleteText'",
  );
  expect(
    deleteButtonFinder,
    findsOneWidget,
    reason: "mistake! The button with the text cannot be found '$deleteText'",
  );

  fancyPrint("Click on the button with the text '$deleteText'");
  await tester.tap(deleteButtonFinder);
  await tester.pumpAndSettle();

  fancyPrint(
    'The MainPage page should not have widgets with the type $widgetName',
  );
  expect(
    memeGridItemFinder,
    findsNothing,
    reason:
        'mistake! The MainPage page contains widgets $widgetName, although they should not',
  );

  fancyPrint('Checking that in SharedPreferences $modelName deleted');

  expect(
    (await SharedPreferences.getInstance()).getStringList(keyInSP) ??
        <String>[],
    <String>[],
    reason: 'mistake! The SharedPreferences remained undelivered $modelName',
  );
}
