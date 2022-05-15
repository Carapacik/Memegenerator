import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

Future<void> expectEmitsInOrderWithTimeoutAndThenDone<T>(
  Stream<T> actual,
  List<T> matcher, {
  String? reason,
  Duration timeoutAfterLastEvent = const Duration(seconds: 1),
}) =>
    expectLater(
      actual.timeout(timeoutAfterLastEvent).onErrorResume((error, stackTrace) {
        if (error is TimeoutException) {
          return Stream<T>.empty();
        } else {
          throw error;
        }
      }),
      emitsInOrder(<dynamic>[...matcher, emitsDone]),
      reason: reason,
    );
