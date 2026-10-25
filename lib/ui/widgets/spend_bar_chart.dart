import 'package:flutter/material.dart';

import '../../logic/date_labels.dart';
import '../../logic/money.dart';
import '../../logic/spending.dart';
import '../theme/app_theme.dart';

/// "Spend per day" bars for the last 7 days. The peak day is highlighted.
///
/// Built from plain widgets rather than a chart package: it is 7 bars, and
/// this keeps full control over the design and the screen-reader label.
class SpendBarChart extends StatelessWidget {
  const SpendBarChart({super.key, required this.week, this.height = 110});

  final WeekSummary week;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    final peak = week.peakIndex;
    final max = peak == null ? 0 : week.days[peak].totalKobo;

    final description = [
      for (final d in week.days)
        '${weekdayLong(d.day)} ${formatNaira(d.totalKobo)}',
    ].join(', ');

    return Semantics(
      label: 'Spend per day. $description',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < week.days.length; i++)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: height,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        // A sliver of bar even on zero days, as in the design.
                        heightFactor: max == 0
                            ? 0.08
                            : (week.days[i].totalKobo / max).clamp(0.08, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: i == peak
                                ? scheme.primary
                                : palette.chartMuted,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    weekdayShort(week.days[i].day),
                    style: i == peak
                        ? AppTextStyles.smallStrong
                        : AppTextStyles.small.copyWith(color: palette.bodyText),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
