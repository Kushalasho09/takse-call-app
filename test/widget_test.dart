import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callyzer/main.dart';
import 'package:callyzer/services/prefs_service.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const TaskCallApp());
    expect(find.byType(TaskCallApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
