import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

void main() {
  testWidgets('Test SVG parsing and rendering', (WidgetTester tester) async {
    final svgString = File('assets/question_art/t1_l1_q1.svg').readAsStringSync();
    expect(svgString.isNotEmpty, true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SvgPicture.string(svgString),
        ),
      ),
    );

    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
