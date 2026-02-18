import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:instadam/providers/app_provider.dart';
import 'package:instadam/screens/settings_screen.dart';
import 'package:instadam/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().init();
  });

  testWidgets('Settings switches language to Spanish', (tester) async {
    final prov = AppProvider();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: prov,
      child: const MaterialApp(home: SettingsScreen()),
    ));

    // default is English
    expect(find.text('Settings'), findsOneWidget);

    // change to Spanish
    prov.setLanguage('es');
    await tester.pumpAndSettle();

    expect(find.text('Ajustes'), findsOneWidget);
  });
}
