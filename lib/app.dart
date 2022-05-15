import 'package:flutter/material.dart';
import 'package:memegenerator/presentation/main/main_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainPage(),
      );
}
