import 'package:flutter/services.dart';

import '../../logic/money.dart';

/// Keeps the amount field to digits, one decimal point and two decimals,
/// and adds thousands commas as the person types: "2500" → "2,500".
class NairaInputFormatter extends TextInputFormatter {
  const NairaInputFormatter({this.maxWholeDigits = 9});

  final int maxWholeDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final dot = raw.indexOf('.');
    var whole = dot == -1 ? raw : raw.substring(0, dot);
    var fraction = dot == -1
        ? null
        : raw.substring(dot + 1).replaceAll('.', '');

    whole = whole.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (whole.length > maxWholeDigits) return oldValue;
    if (fraction != null && fraction.length > 2) {
      fraction = fraction.substring(0, 2);
    }
    if (whole.isEmpty && fraction != null) whole = '0';

    final text = fraction == null
        ? groupThousands(whole)
        : '${groupThousands(whole)}.$fraction';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
