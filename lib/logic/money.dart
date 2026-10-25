/// The one place money is turned into text, and text into money.
library;

/// ₦2,500 for whole naira, ₦1,250.50 otherwise.
String formatNaira(int kobo) {
  final sign = kobo < 0 ? '-' : '';
  final abs = kobo.abs();
  final naira = groupThousands((abs ~/ 100).toString());
  final rest = abs % 100;
  final decimals = rest == 0 ? '' : '.${rest.toString().padLeft(2, '0')}';
  return '$sign₦$naira$decimals';
}

/// Inserts commas: "1234567" → "1,234,567".
String groupThousands(String digits) {
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

/// Parses what someone typed ("2,500", "1250.5") into kobo.
///
/// Returns null for anything that is not a plain amount with at most two
/// decimal places.
int? parseNairaToKobo(String input) {
  final text = input.replaceAll(',', '').trim();
  final match = RegExp(r'^(\d+)(?:\.(\d{0,2}))?$').firstMatch(text);
  if (match == null) return null;
  final naira = int.parse(match[1]!);
  final fraction = (match[2] ?? '').padRight(2, '0');
  return naira * 100 + int.parse(fraction);
}
