// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:instadam/main.dart';
import 'package:instadam/providers/app_provider.dart';
import 'package:instadam/screens/login_screen.dart';

void main() {
  testWidgets('Splash announces loading state and navigates to login', (
    WidgetTester tester,
  ) async {
    // Build our app wrapped with the required provider and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MyApp(),
      ),
    );

    expect(find.text('InstaDAM'), findsOneWidget);
    expect(find.text('Loading application'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
