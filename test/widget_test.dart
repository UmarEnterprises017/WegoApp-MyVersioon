import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wego_marriage/main.dart';
import 'package:wego_marriage/providers/story_provider.dart';
import 'package:wego_marriage/providers/user_provider.dart';
import 'package:wego_marriage/providers/settings_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => StoryProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the splash screen shows the app name.
    expect(find.text('WeGo\nMarriage'), findsOneWidget);
    expect(find.text('Matrimonial App'), findsOneWidget);
  });
}
