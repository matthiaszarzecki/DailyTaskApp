import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_task_app/main.dart';

void main() {
  // TODO(MZ): Add unit-tests for datetime-checker

  // Set fake "today" time
  // Set Reset time for the day after
  // Set "today" to the next day
  // Check if shouldResetValues returns true
  
  
  testWidgets(
    'Counter increments smoke test',
    (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(DailyTaskApp());

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    },
  );
}
