import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend_tracker_ogbm/logic/money.dart';

void main() {
  group('formatNaira', () {
    test('whole naira has no decimals', () {
      expect(formatNaira(0), '₦0');
      expect(formatNaira(250000), '₦2,500');
      expect(formatNaira(4580000), '₦45,800');
      expect(formatNaira(123456700), '₦1,234,567');
    });

    test('part naira shows two decimals', () {
      expect(formatNaira(125050), '₦1,250.50');
      expect(formatNaira(654286), '₦6,542.86');
      expect(formatNaira(5), '₦0.05');
    });

    test('negative amounts', () {
      expect(formatNaira(-200000), '-₦2,000');
    });
  });

  group('parseNairaToKobo', () {
    test('accepts plain and grouped amounts', () {
      expect(parseNairaToKobo('2500'), 250000);
      expect(parseNairaToKobo('2,500'), 250000);
      expect(parseNairaToKobo(' 1250.5 '), 125050);
      expect(parseNairaToKobo('1,250.50'), 125050);
      expect(parseNairaToKobo('3.'), 300);
    });

    test('rejects anything else', () {
      expect(parseNairaToKobo(''), isNull);
      expect(parseNairaToKobo('abc'), isNull);
      expect(parseNairaToKobo('1.234'), isNull);
      expect(parseNairaToKobo('-5'), isNull);
      expect(parseNairaToKobo('1.2.3'), isNull);
    });
  });
}
