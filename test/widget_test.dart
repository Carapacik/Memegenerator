import 'package:flutter_test/flutter_test.dart';

import 'lesson_4/test_1.dart';
import 'lesson_4/test_2.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("test1", () => runTest1());
  group("test2", () => runTest2());
}
