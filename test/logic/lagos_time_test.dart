import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend_tracker_ogbm/logic/date_labels.dart';
import 'package:naira_spend_tracker_ogbm/logic/lagos_time.dart';

void main() {
  test('23:30 UTC is already the next day in Lagos', () {
    final day = LagosDay.of(DateTime.utc(2026, 10, 9, 23, 30));
    expect(day, LagosDay(2026, 10, 10));
  });

  test('a Lagos day starts at 23:00 UTC the evening before', () {
    expect(LagosDay(2026, 10, 10).start, DateTime.utc(2026, 10, 9, 23));
  });

  test('month start and day arithmetic cross month ends', () {
    final day = LagosDay(2026, 3, 1);
    expect(day.addDays(-1), LagosDay(2026, 2, 28));
    expect(LagosDay(2026, 10, 31).firstOfMonth, LagosDay(2026, 10, 1));
  });

  test('labels', () {
    final today = LagosDay(2026, 10, 10); // Saturday
    expect(weekdayShort(today), 'Sat');
    expect(relativeDay(today, today), 'Today');
    expect(relativeDay(today.addDays(-1), today), 'Yesterday');
    expect(relativeDay(today.addDays(-4), today), 'Tue 6 Oct');
    expect(onDay(today.addDays(-4), today), 'on Tuesday');
    expect(onDay(today.addDays(-20), today), 'on 20 Sep');
    expect(monthYear(today), 'October 2026');
    expect(greeting(DateTime.utc(2026, 10, 10, 13)), 'Good afternoon');
  });
}
