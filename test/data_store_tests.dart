import 'package:flutter_test/flutter_test.dart';

import 'package:daily_task_app/utilities/data_store.dart';

void main() {
  test('Next Reset Date should be correctly set in the middle of the month', () {
    // GIVEN we have an arbitrary date
    DateTime testDate = DateTime(2020, 01, 15);

    // AND we want the next reset-date that comes afterwards
    DateTime testResetDate = DataStore.getNextResetDateFrom(testDate);

    // THEN the date we get is at 0400 hours
    expect(testResetDate.hour, 4);

    // THEN the date we get is on the next calendar-day
    expect(testResetDate.day, testDate.day + 1);
  });

  test('Next Reset Date should be correctly set at the end of the month', () {
    // GIVEN we have an arbitrary date
    DateTime testDate = DateTime(2020, 01, 31);

    // AND we want the next reset-date that comes afterwards
    DateTime testResetDate = DataStore.getNextResetDateFrom(testDate);

    // THEN the date we get is at 0400 hours
    expect(testResetDate.hour, 4);

    // THEN the date we get is on the next calendar-day
    expect(testResetDate.day, 1);
  });
}
