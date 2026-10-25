import 'package:flutter/material.dart';

import '../../logic/date_labels.dart';
import '../../logic/lagos_time.dart';
import '../../logic/money.dart';
import '../../logic/spending.dart';
import '../app/app_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_track.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  InsightsPeriod _period = InsightsPeriod.last30Days;

  @override
  Widget build(BuildContext context) {
    final spending = AppScope.spendingOf(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: spending,
          builder: (context, _) {
            if (spending.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final summary = spending.summary(_period);
            final today = LagosDay.of(spending.now);
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                Text('Insights', style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.lg),
                _PeriodTabs(
                  selected: _period,
                  onSelected: (p) => setState(() => _period = p),
                ),
                const SizedBox(height: AppSpacing.lg),
                _TotalCard(period: _period, summary: summary),
                const SizedBox(height: AppSpacing.md),
                if (summary.count > 0) ...[
                  _ByCategoryCard(summary: summary),
                  const SizedBox(height: AppSpacing.md),
                  _BiggestExpenseTip(summary: summary, today: today),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Pill-style segmented control from the design.
class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.selected, required this.onSelected});

  final InsightsPeriod selected;
  final ValueChanged<InsightsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: palette.segmentBg,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        children: [
          for (final p in InsightsPeriod.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: p == selected,
                inMutuallyExclusiveGroup: true,
                child: Material(
                  color: p == selected ? palette.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  child: InkWell(
                    key: Key('insights.period.${p.name}'),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    onTap: () => onSelected(p),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        p.label,
                        style: p == selected
                            ? AppTextStyles.smallStrong
                            : AppTextStyles.small.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.period, required this.summary});

  final InsightsPeriod period;
  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final count = summary.count;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              period.heading,
              style: AppTextStyles.small.copyWith(color: palette.bodyText),
            ),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                formatNaira(summary.totalKobo),
                style: AppTextStyles.amountLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              count == 0
                  ? 'No expenses in this period'
                  : 'Across $count ${count == 1 ? 'expense' : 'expenses'}',
              style: AppTextStyles.small.copyWith(color: palette.bodyText),
            ),
          ],
        ),
      ),
    );
  }
}

class _ByCategoryCard extends StatelessWidget {
  const _ByCategoryCard({required this.summary});

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    final largest = summary.byCategory.first.totalKobo;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By category', style: AppTextStyles.bodyStrong),
            for (final share in summary.byCategory) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      share.category.label,
                      style: AppTextStyles.smallStrong,
                    ),
                  ),
                  Text(
                    '${formatNaira(share.totalKobo)} · '
                    '${(share.share * 100).round()}%',
                    style: AppTextStyles.smallMedium.copyWith(
                      color: palette.bodyText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Bars are relative to the largest category, as in the design.
              ProgressTrack(
                fraction: share.totalKobo / largest,
                color: scheme.primary,
                trackColor: palette.track,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BiggestExpenseTip extends StatelessWidget {
  const _BiggestExpenseTip({required this.summary, required this.today});

  final PeriodSummary summary;
  final LagosDay today;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final biggest = summary.biggest!;
    final style = AppTextStyles.small.copyWith(color: palette.warningInk);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.warningBg,
        border: Border.all(color: palette.warningBorder),
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: palette.warningText, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: style,
                children: [
                  const TextSpan(text: 'Your biggest single expense was '),
                  TextSpan(
                    text:
                        '${biggest.title}, ${formatNaira(biggest.amountKobo)}',
                    style: style.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' ${onDay(LagosDay.of(biggest.date), today)}.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
