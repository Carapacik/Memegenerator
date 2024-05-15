import 'package:flutter_test/flutter_test.dart';

Matcher isOneOrAnother(Object one, Object another) =>
    OneOrAnotherMatcher(one, another);

class OneOrAnotherMatcher extends Matcher {
  const OneOrAnotherMatcher(this._one, this._another);

  final dynamic _one;
  final dynamic _another;

  @override
  Description describe(Description description) {
    return description.add(
      'either ${_one.runtimeType}:<$_one> or ${_another.runtimeType}:<$_another>',
    );
  }

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item == _one || item == _another;
}
