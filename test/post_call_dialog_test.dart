import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:callyzer/widgets/post_call_lead_status_dialog.dart';

void main() {
  testWidgets('PostCallLeadStatusDialog renders caller details, Callyzer statuses, and Image 1 buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(480, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: PostCallLeadStatusDialog(
            phoneNumber: '+91 9978217711',
            contactName: 'ASODIA KUSHAL',
            callType: 'outgoing',
            durationSeconds: 0,
            ringingSeconds: 2,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify header and telecaller details
    expect(find.text('Last Call Details'), findsOneWidget);
    expect(find.text('ASODIA KUSHAL'), findsOneWidget);
    expect(find.text('+91 9978217711'), findsOneWidget);

    // 2. Verify 4 Image 2 Lead Statuses
    expect(find.text('Lead Status'), findsOneWidget);
    expect(find.text('Positive'), findsOneWidget);
    expect(find.text('Call Back'), findsOneWidget);
    expect(find.text('Negative'), findsOneWidget);
    expect(find.text('Not Pickup Call'), findsOneWidget);

    // 3. Tap "Call Back" status to reveal reminder picker
    await tester.tap(find.text('Call Back'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.alarm_on_rounded), findsOneWidget);

    // 4. Verify Note section with hint and mic
    expect(find.text('Add Note'), findsOneWidget);
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);

    // 5. Verify the 3 Image 1 Action Buttons
    expect(find.text('Save & Exit'), findsOneWidget);
    expect(find.text('Save & Connect'), findsOneWidget);
    expect(find.text('Save & Add Lead'), findsOneWidget);
  });
}
