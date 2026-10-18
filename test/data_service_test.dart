import 'package:flutter_test/flutter_test.dart';
import 'package:safequest/services/data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  test('Check all 120 questions have existing PNG files on disk and end with .png', () async {
    SharedPreferences.setMockInitialValues({});
    final ds = DataService();
    await ds.init();
    final questions = await ds.getQuestions();

    expect(questions.length, 120);
    for (var q in questions) {
      expect(q.image, isNotNull);
      expect(q.image!.endsWith('.png'), true, reason: 'Question ${q.id} image is ${q.image}');
      
      final file = File(q.image!);
      expect(file.existsSync(), true, reason: 'File does not exist on disk: ${q.image}');
    }
    print('Verified all 120 questions have valid, existing .png files!');
  });
}
