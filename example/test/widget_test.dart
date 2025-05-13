import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formwiz_example/main.dart';

void main() {
  testWidgets('Smoke test - check if app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const FormWizExampleApp());
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });
} 