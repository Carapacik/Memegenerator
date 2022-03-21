import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memogenerator/app.dart';

void main() {
  EquatableConfig.stringify = true;
  runApp(const App());
}
