import 'package:flutter/material.dart';
import 'package:formwiz_example/presentation/views/form_example/form_example_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormWiz Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: const FormExampleView(),
    );
  }
}
