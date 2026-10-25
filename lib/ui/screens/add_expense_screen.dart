import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../../logic/date_labels.dart';
import '../../logic/expense_validation.dart';
import '../../logic/lagos_time.dart';
import '../../logic/money.dart';
import '../app/app_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/category_style.dart';
import '../widgets/naira_input_formatter.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _title = TextEditingController();
  ExpenseCategory? _category;
  LagosDay? _day;
  bool _submitted = false;

  @override
  void dispose() {
    _amount.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate(LagosDay today) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (_day ?? today).asLocalDate,
      firstDate: today.addDays(-365).asLocalDate,
      lastDate: today.asLocalDate,
      helpText: 'When did you spend it?',
    );
    if (picked != null) setState(() => _day = LagosDay.fromLocalDate(picked));
  }

  void _save() {
    setState(() => _submitted = true);
    final formValid = _formKey.currentState!.validate();
    if (!formValid || _category == null) return;

    final spending = AppScope.spendingOf(context);
    final now = spending.now;
    final today = LagosDay.of(now);
    final day = _day ?? today;
    spending.addExpense(
      NewExpense(
        title: _title.text.trim(),
        amountKobo: parseNairaToKobo(_amount.text)!,
        category: _category!,
        // Today keeps the real time, so it sorts above earlier entries.
        date: day == today ? now : day.noon,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    final today = LagosDay.of(AppScope.spendingOf(context).now);
    final day = _day ?? today;
    final labelStyle = AppTextStyles.smallStrong.copyWith(
      color: palette.bodyText,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          key: const Key('add.close'),
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Text('Add expense', style: AppTextStyles.h3),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                    vertical: AppSpacing.md,
                  ),
                  children: [
                    Text('Amount', style: labelStyle),
                    TextFormField(
                      key: const Key('add.amount'),
                      controller: _amount,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: const [NairaInputFormatter()],
                      textInputAction: TextInputAction.next,
                      style: AppTextStyles.amountHero,
                      validator: (v) => validateAmount(v ?? ''),
                      decoration: InputDecoration(
                        filled: false,
                        hintText: '0',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: AppSpacing.sm,
                          ),
                          child: Text(
                            '₦',
                            style: AppTextStyles.amountHero.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: scheme.primary),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: scheme.primary),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: scheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: scheme.error),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: scheme.error, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('What did you buy?', style: labelStyle),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      key: const Key('add.title'),
                      controller: _title,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: maxTitleLength,
                      validator: (v) => validateTitle(v ?? ''),
                      style: AppTextStyles.body,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Suya',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Category', style: labelStyle),
                    const SizedBox(height: AppSpacing.sm),
                    _CategoryGrid(
                      selected: _category,
                      onSelected: (c) => setState(() => _category = c),
                    ),
                    if (_submitted && _category == null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          'Choose a category',
                          style: AppTextStyles.caption.copyWith(
                            color: scheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                    _DateRow(
                      label: relativeDay(day, today),
                      onChange: () => _pickDate(today),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.screen,
                  AppSpacing.lg,
                ),
                child: FilledButton.icon(
                  key: const Key('add.save'),
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Save expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.selected, required this.onSelected});

  final ExpenseCategory? selected;
  final ValueChanged<ExpenseCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.55,
      children: [
        for (final c in ExpenseCategory.values)
          _CategoryTile(
            category: c,
            selected: c == selected,
            onTap: () => onSelected(c),
          ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    final fg = selected ? scheme.onPrimaryContainer : palette.bodyText;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.tile),
      side: selected
          ? BorderSide(color: scheme.primary, width: 2)
          : BorderSide(color: palette.border),
    );
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? scheme.primaryContainer : palette.card,
        shape: shape,
        child: InkWell(
          key: Key('add.category.${category.id}'),
          customBorder: shape,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 20, color: fg),
              const SizedBox(height: AppSpacing.xs),
              Text(
                category.label,
                style:
                    (selected ? AppTextStyles.smallStrong : AppTextStyles.small)
                        .copyWith(color: selected ? fg : scheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.onChange});

  final String label;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: scheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body,
                semanticsLabel: 'Date: $label',
              ),
            ),
            TextButton(
              key: const Key('add.changeDate'),
              onPressed: onChange,
              child: const Text('Change date'),
            ),
          ],
        ),
      ),
    );
  }
}
