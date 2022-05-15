import 'package:flutter_test/flutter_test.dart';

import 'main_test/test_1.dart';
import 'main_test/test_2.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('test1', runTest1);
  group('test2', runTest2);
}
