import 'package:flutter/material.dart';

import '../../data/models/expense.dart';
import '../../logic/date_labels.dart';
import '../../logic/lagos_time.dart';
import '../../logic/money.dart';
import '../theme/app_theme.dart';
import 'category_style.dart';

/// Icon, title, "Category · Day", amount and a delete button.
class ExpenseRow extends StatelessWidget {
  const ExpenseRow({
    super.key,
    required this.expense,
    required this.today,
    required this.onDelete,
  });

  final Expense expense;
  final LagosDay today;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final subtitle =
        '${expense.category.label} · '
        '${relativeDay(LagosDay.of(expense.date), today)}';
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          CategoryBadge(expense.category),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: AppTextStyles.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.small.copyWith(color: palette.bodyText),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(formatNaira(expense.amountKobo), style: AppTextStyles.amountRow),
          IconButton(
            key: Key('expense.delete.${expense.id}'),
            onPressed: onDelete,
            tooltip: 'Delete ${expense.title}',
            icon: Icon(Icons.delete_outline, color: palette.bodyText),
          ),
        ],
      ),
    );
  }
}
