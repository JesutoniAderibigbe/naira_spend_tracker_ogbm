import 'package:flutter/material.dart';

import '../../logic/budget_status.dart';
import '../../logic/money.dart';
import '../theme/app_theme.dart';
import 'progress_track.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key, required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final colors = BudgetStatusColors.of(context);
    final style = switch (progress.status) {
      BudgetStatus.fine => colors.fine,
      BudgetStatus.near => colors.near,
      BudgetStatus.atLimit => colors.atLimit,
      BudgetStatus.over => colors.over,
    };
    final spent = formatNaira(progress.spentKobo);
    final limit = formatNaira(progress.limitKobo);

    return Card(
      child: Semantics(
        container: true,
        label:
            '${progress.category.label}: $spent of $limit. '
            '${progress.statusText}',
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      progress.category.label,
                      style: AppTextStyles.title,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: spent, style: AppTextStyles.smallStrong),
                        TextSpan(
                          text: ' of $limit',
                          style: AppTextStyles.small.copyWith(
                            color: palette.bodyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ProgressTrack(
                fraction: progress.fraction,
                color: style.bar,
                trackColor: style.track,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                progress.statusText,
                style: AppTextStyles.smallStrong.copyWith(color: style.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
