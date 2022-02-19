import 'package:flutter/painting.dart';

class AppColors {
  AppColors._();

  static const lemon = Color(0xFFFFE600);

  static const fuchsia = Color(0xFFD9005D);
  static final fuchsia16 =
      Color.fromRGBO(fuchsia.red, fuchsia.green, fuchsia.blue, 0.16);
  static final fuchsia38 =
      Color.fromRGBO(fuchsia.red, fuchsia.green, fuchsia.blue, 0.38);

  static const darkGrey = Color(0xFF333333);
  static final darkGrey6 =
      Color.fromRGBO(darkGrey.red, darkGrey.green, darkGrey.blue, 0.06);
  static final darkGrey16 =
      Color.fromRGBO(darkGrey.red, darkGrey.green, darkGrey.blue, 0.16);
  static final darkGrey38 =
      Color.fromRGBO(darkGrey.red, darkGrey.green, darkGrey.blue, 0.38);
}
