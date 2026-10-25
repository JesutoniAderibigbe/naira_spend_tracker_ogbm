/// Validation for the Add expense form. Each returns an error or null.
library;

import 'money.dart';

const maxTitleLength = 60;

/// ₦100,000,000 cap, to catch an extra zero or two.
const maxAmountKobo = 100000000 * 100;

String? validateAmount(String input) {
  if (input.trim().isEmpty) return 'Enter an amount';
  final kobo = parseNairaToKobo(input);
  if (kobo == null) return 'Enter a valid amount, like 2,500';
  if (kobo <= 0) return 'Amount must be more than ₦0';
  if (kobo > maxAmountKobo) return 'That amount is too large';
  return null;
}

String? validateTitle(String input) {
  final title = input.trim();
  if (title.isEmpty) return 'Say what you bought';
  if (title.length > maxTitleLength) {
    return 'Keep it under $maxTitleLength characters';
  }
  return null;
}
