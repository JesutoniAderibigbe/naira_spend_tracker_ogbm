/// Human-readable dates, all in Lagos time.
library;

import 'lagos_time.dart';

const _weekdaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekdaysLong = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _monthsLong = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];

String weekdayShort(LagosDay day) => _weekdaysShort[day.weekday - 1];

String weekdayLong(LagosDay day) => _weekdaysLong[day.weekday - 1];

/// "October 2026".
String monthYear(LagosDay day) => '${_monthsLong[day.month - 1]} ${day.year}';

/// "Today", "Yesterday", or "Tue 7 Oct".
String relativeDay(LagosDay day, LagosDay today) {
  if (day == today) return 'Today';
  if (day == today.addDays(-1)) return 'Yesterday';
  return '${weekdayShort(day)} ${day.day} ${_monthsShort[day.month - 1]}';
}

/// "on Tuesday" within the last week, otherwise "on 3 Oct".
String onDay(LagosDay day, LagosDay today) {
  if (day == today) return 'today';
  if (day == today.addDays(-1)) return 'yesterday';
  if (!today.addDays(-6).start.isAfter(day.start)) {
    return 'on ${weekdayLong(day)}';
  }
  return 'on ${day.day} ${_monthsShort[day.month - 1]}';
}

String greeting(DateTime now) {
  final hour = now.toUtc().add(lagosOffset).hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
