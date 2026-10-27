import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/screens/home/home_screen.dart';
import 'package:safequest/screens/lessons/video_lessons_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Video Lessons Banner and 4 Topics with 3 Videos each test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));

    // Register & Login child account
    await provider.register('be_an', '123456');
    await provider.login('be_an', '123456');
    await provider.saveProfile('Bé An', 6, '👦');

    // 1. Render HomeScreen
    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check banner presence: "Video Bài Giảng" and "XEM", no "GÓC XEM PHIM"
    expect(find.byKey(const Key('video_lessons_banner_button')), findsOneWidget);
    expect(find.text('GÓC XEM PHIM'), findsNothing);
    expect(find.text('Video Bài Giảng'), findsOneWidget);
    expect(find.text('4 chủ đề kĩ năng sinh động'), findsOneWidget);
    expect(find.text('XEM'), findsOneWidget);

    // 2. Tap on the Video Lessons Banner
    await tester.tap(find.byKey(const Key('video_lessons_banner_button')));
    await tester.pumpAndSettle();

    // Verify VideoLessonsScreen is pushed
    expect(find.byType(VideoLessonsScreen), findsOneWidget);
    expect(find.text('Rạp Chiếu Bài Học An Toàn'), findsOneWidget);
    expect(find.text('4 Chủ đề'), findsOneWidget);

    // Check that all 4 topics are visible in the topic selector
    expect(find.text('An toàn giao thông'), findsWidgets);
    expect(find.text('An toàn trong nhà'), findsWidgets);
    expect(find.text('An toàn ngoài trời'), findsWidgets);
    expect(find.text('An toàn với người lạ'), findsWidgets);

    // Check topic 1 default videos (3 video cards with badges and NO surrounding explanation text)
    expect(find.text('Bài 1 / 3'), findsOneWidget);
    expect(find.text('Bài 2 / 3'), findsOneWidget);
    expect(find.text('Bài 3 / 3'), findsOneWidget);
    expect(find.text('PHÁT VIDEO'), findsWidgets);
    expect(find.text('Nhận biết tín hiệu đèn giao thông & vạch kẻ đường'), findsNothing);

    // 3. Tap on the first video card to open preview dialog
    await tester.tap(find.text('PHÁT VIDEO').first);
    await tester.pumpAndSettle();

    expect(find.text('Chuẩn Bị Video Bài Giảng'), findsOneWidget);
    expect(find.textContaining('Đã gắn link YouTube'), findsOneWidget);
    expect(find.text('MỞ XEM TRÊN YOUTUBE 🚀'), findsOneWidget);
    expect(find.text('ĐÃ HIỂU'), findsOneWidget);

    // Close the dialog
    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pumpAndSettle();

    // 4. Switch to Topic 2 ("An toàn trong nhà")
    await tester.ensureVisible(find.text('An toàn trong nhà').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('An toàn trong nhà').first);
    await tester.pumpAndSettle();

    // Verify 3 video cards for Topic 2 and no explanation text
    expect(find.text('Bài 1 / 3'), findsOneWidget);
    expect(find.text('Bài 2 / 3'), findsOneWidget);
    expect(find.text('Bài 3 / 3'), findsOneWidget);
    expect(find.text('Phòng tránh bỏng và nguy hiểm từ nước sôi, bếp lửa'), findsNothing);

    // 5. Switch to Topic 3 ("An toàn ngoài trời")
    await tester.ensureVisible(find.text('An toàn ngoài trời').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('An toàn ngoài trời').first);
    await tester.pumpAndSettle();

    expect(find.text('Bài 1 / 3'), findsOneWidget);
    expect(find.text('Quy tắc an toàn khi chơi gần ao, hồ, sông suối'), findsNothing);

    // 6. Switch to Topic 4 ("An toàn với người lạ")
    await tester.ensureVisible(find.text('An toàn với người lạ').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('An toàn với người lạ').first);
    await tester.pumpAndSettle();

    expect(find.text('Bài 1 / 3'), findsOneWidget);
    expect(find.text('Quy tắc 5 ngón tay phòng chống xâm hại'), findsNothing);

    // 7. Test Quick Practice Button navigation to TopicDetailScreen
    await tester.ensureVisible(find.text('LÀM BÀI TẬP ÔN LUYỆN CHỦ ĐỀ NÀY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LÀM BÀI TẬP ÔN LUYỆN CHỦ ĐỀ NÀY'));
    await tester.pumpAndSettle();

    // Verify we are in TopicDetailScreen for "An toàn với người lạ"
    expect(find.byType(VideoLessonsScreen), findsNothing);

    // Navigate back to VideoLessonsScreen
    final backBtn = find.byTooltip('Back');
    if (backBtn.evaluate().isNotEmpty) {
      await tester.tap(backBtn);
    } else {
      // In custom app bar with back button or navigator pop
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
    }
    await tester.pumpAndSettle();

    expect(find.byType(VideoLessonsScreen), findsOneWidget);

    // 8. Tap "QUAY LẠI" button to go back to HomeScreen
    await tester.tap(find.text('QUAY LẠI'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Admin can edit YouTube link and save to Firestore/local', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));

    // Login as default admin
    final loggedIn = await provider.login('admin', '123');
    expect(loggedIn, true);
    expect(provider.isAdmin, true);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: VideoLessonsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on first video
    await tester.tap(find.text('PHÁT VIDEO').first);
    await tester.pumpAndSettle();

    // Verify Admin box is shown
    expect(find.text('ADMIN: GẮN LINK YOUTUBE'), findsOneWidget);
    expect(find.text('LƯU VÀO FIREBASE'), findsOneWidget);

    // Enter YouTube URL
    await tester.enterText(find.byType(TextField), 'https://www.youtube.com/watch?v=safety123');
    await tester.pumpAndSettle();

    // Tap save
    await tester.tap(find.text('LƯU VÀO FIREBASE'));
    await tester.pumpAndSettle();

    // Verify dialog dismissed and snackbar shown
    expect(find.text('ADMIN: GẮN LINK YOUTUBE'), findsNothing);
    expect(find.textContaining('Đã cập nhật link video lên Firebase'), findsOneWidget);

    // Verify updated in provider
    final updatedVideo = provider.getVideosForTopic('t1').first;
    expect(updatedVideo.youtubeUrl, 'https://www.youtube.com/watch?v=safety123');
  });
}
