import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Matches `Color(0x...)`, with or without `const` and spaces.
final _hexColor = RegExp(r'\bColor\s*\(\s*0x', caseSensitive: false);

/// Lines under lib/ui that declare a hex colour outside lib/ui/theme/.
List<String> findHardcodedColors(Directory uiDir) {
  final themeDir = '${uiDir.path}/theme/';
  final hits = <String>[];
  for (final file in uiDir.listSync(recursive: true).whereType<File>()) {
    final path = file.path.replaceAll(r'\', '/');
    if (!path.endsWith('.dart') || path.startsWith(themeDir)) continue;
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (_hexColor.hasMatch(lines[i])) {
        hits.add('$path:${i + 1}: ${lines[i].trim()}');
      }
    }
  }
  return hits;
}

void main() {
  test('pattern catches hex colours and ignores theme lookups', () {
    expect(_hexColor.hasMatch('const Color(0xFF008751)'), isTrue);
    expect(_hexColor.hasMatch('Color( 0xff008751 )'), isTrue);
    expect(_hexColor.hasMatch('Colors.red'), isFalse);
    expect(_hexColor.hasMatch('scheme.primary'), isFalse);
  });

  test('no Color(0x...) under lib/ui outside lib/ui/theme/', () {
    final hits = findHardcodedColors(Directory('lib/ui'));
    expect(
      hits,
      isEmpty,
      reason:
          'Use Theme.of(context), AppPalette or BudgetStatusColors instead:\n'
          '${hits.join('\n')}',
    );
  });
}
