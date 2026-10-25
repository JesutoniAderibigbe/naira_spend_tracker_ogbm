import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import '../../logic/budget_status.dart';
import '../../logic/date_labels.dart';
import '../../logic/lagos_time.dart';
import '../../logic/money.dart';
import '../../logic/spending_controller.dart';
import '../app/app_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/budget_card.dart';
import '../widgets/naira_input_formatter.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spending = AppScope.spendingOf(context);
    final palette = AppPalette.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: spending,
          builder: (context, _) {
            if (spending.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final budgets = spending.budgets;
            final over = budgets
                .where((b) => b.status == BudgetStatus.over)
                .toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            monthYear(LagosDay.of(spending.now)),
                            style: AppTextStyles.body.copyWith(
                              color: palette.bodyText,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Budgets', style: AppTextStyles.h1),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      key: const Key('budgets.edit'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(64, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                      ),
                      onPressed: () => _editLimits(context, spending),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (over.isNotEmpty) ...[
                  _OverBudgetAlert(over: over),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (budgets.isEmpty)
                  _NoBudgets(onEdit: () => _editLimits(context, spending))
                else
                  for (final b in budgets) ...[
                    BudgetCard(key: ValueKey(b.category), progress: b),
                    const SizedBox(height: AppSpacing.md),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _editLimits(BuildContext context, SpendingController spending) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditLimitsSheet(spending: spending),
    );
  }
}

class _OverBudgetAlert extends StatelessWidget {
  const _OverBudgetAlert({required this.over});

  final List<BudgetProgress> over;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final title = over.length == 1
        ? '${over.first.category.label} is '
              '${formatNaira(over.first.spentKobo - over.first.limitKobo)} '
              'over budget'
        : '${over.length} budgets are over the limit';
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: palette.dangerBg,
          border: Border.all(color: palette.dangerBorder),
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: palette.dangerText),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: palette.dangerText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Raise the limit or cut back for the rest of the month.',
                    style: AppTextStyles.small.copyWith(
                      color: palette.dangerInk,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoBudgets extends StatelessWidget {
  const _NoBudgets({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Text(
              'No budgets yet',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Set a monthly limit for a category to see how much is left.',
              textAlign: TextAlign.center,
              style: AppTextStyles.small.copyWith(
                color: AppPalette.of(context).bodyText,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              key: const Key('budgets.setFirst'),
              onPressed: onEdit,
              child: const Text('Set budgets'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Monthly limit per category. Empty means no budget for that category.
class _EditLimitsSheet extends StatefulWidget {
  const _EditLimitsSheet({required this.spending});

  final SpendingController spending;

  @override
  State<_EditLimitsSheet> createState() => _EditLimitsSheetState();
}

class _EditLimitsSheetState extends State<_EditLimitsSheet> {
  final _formKey = GlobalKey<FormState>();
  late final Map<ExpenseCategory, TextEditingController> _fields = {
    for (final c in ExpenseCategory.values)
      c: TextEditingController(
        text: switch (widget.spending.limits[c]) {
          final kobo? => formatNaira(kobo).substring(1),
          null => '',
        },
      ),
  };

  @override
  void dispose() {
    for (final f in _fields.values) {
      f.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    for (final MapEntry(key: category, value: field) in _fields.entries) {
      final kobo = field.text.trim().isEmpty
          ? null
          : parseNairaToKobo(field.text);
      if (kobo != widget.spending.limits[category]) {
        widget.spending.setLimit(category, kobo);
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Monthly limits', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Leave a category empty to have no budget for it.',
                  style: AppTextStyles.small.copyWith(color: palette.bodyText),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final c in ExpenseCategory.values) ...[
                  TextFormField(
                    key: Key('budgets.limit.${c.id}'),
                    controller: _fields[c],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [NairaInputFormatter()],
                    textInputAction: c == ExpenseCategory.values.last
                        ? TextInputAction.done
                        : TextInputAction.next,
                    validator: (v) {
                      final text = v?.trim() ?? '';
                      if (text.isEmpty) return null;
                      final kobo = parseNairaToKobo(text);
                      if (kobo == null || kobo <= 0) {
                        return 'Enter an amount above ₦0, or leave it empty';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: c.label,
                      prefixText: '₦ ',
                      hintText: 'No limit',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: AppSpacing.sm),
                FilledButton(
                  key: const Key('budgets.save'),
                  onPressed: _save,
                  child: const Text('Save limits'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
