/// Calendar maths in Africa/Lagos time.
///
/// Lagos is West Africa Time, UTC+1 all year (no daylight saving), so a fixed
/// offset is exact and no timezone database is needed.
library;

/// Returns the current instant. Inject one so tests control "now".
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now().toUtc();

const lagosOffset = Duration(hours: 1);

/// A Lagos calendar day, stored as a UTC date at midnight (no time part).
extension type const LagosDay._(DateTime _date) {
  /// The Lagos day that [instant] falls on.
  factory LagosDay.of(DateTime instant) {
    final wall = instant.toUtc().add(lagosOffset);
    return LagosDay._(DateTime.utc(wall.year, wall.month, wall.day));
  }

  factory LagosDay(int year, int month, int day) =>
      LagosDay._(DateTime.utc(year, month, day));

  int get year => _date.year;
  int get month => _date.month;
  int get day => _date.day;

  /// [DateTime.monday] to [DateTime.sunday].
  int get weekday => _date.weekday;

  /// The instant this day starts in Lagos.
  DateTime get start => _date.subtract(lagosOffset);

  /// Midday in Lagos: a safe instant for a date picked without a time.
  DateTime get noon => start.add(const Duration(hours: 12));

  LagosDay addDays(int days) =>
      LagosDay._(DateTime.utc(year, month, day + days));

  LagosDay get firstOfMonth => LagosDay(year, month, 1);

  /// Calendar dates for the date picker (which works in local DateTimes).
  DateTime get asLocalDate => DateTime(year, month, day);

  static LagosDay fromLocalDate(DateTime date) =>
      LagosDay(date.year, date.month, date.day);
}
