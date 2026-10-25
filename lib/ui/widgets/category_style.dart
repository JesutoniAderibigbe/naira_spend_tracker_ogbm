import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import '../theme/app_theme.dart';

/// Icon and colours for each category.
extension CategoryStyle on ExpenseCategory {
  IconData get icon => switch (this) {
    ExpenseCategory.food => Icons.rice_bowl_outlined,
    ExpenseCategory.transport => Icons.directions_bus_outlined,
    ExpenseCategory.data => Icons.signal_cellular_alt_rounded,
    ExpenseCategory.bills => Icons.bolt_outlined,
    ExpenseCategory.fun => Icons.star_outline_rounded,
    ExpenseCategory.other => Icons.receipt_long_outlined,
  };

  CategoryColors colorsIn(AppPalette palette) => switch (this) {
    ExpenseCategory.food => palette.food,
    ExpenseCategory.transport => palette.transport,
    ExpenseCategory.data => palette.data,
    ExpenseCategory.bills => palette.bills,
    ExpenseCategory.fun => palette.fun,
    ExpenseCategory.other => palette.other,
  };
}

/// The rounded square icon at the start of an expense row.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge(this.category, {super.key});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = category.colorsIn(AppPalette.of(context));
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Icon(category.icon, size: 20, color: colors.fg),
    );
  }
}
