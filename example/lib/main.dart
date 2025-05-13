import 'package:flutter/material.dart';
import 'package:formwiz_example/presentation/core/app_theme.dart';
import 'package:formwiz_example/presentation/views/home/home_view.dart';

void main() {
  runApp(const FormWizExampleApp());
}

class FormWizExampleApp extends StatelessWidget {
  const FormWizExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormWiz Example',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomeView(),
    );
  }
}
