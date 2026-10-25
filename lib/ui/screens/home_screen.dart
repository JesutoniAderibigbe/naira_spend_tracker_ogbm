import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/app_user.dart';
import '../../data/models/expense.dart';
import '../../logic/date_labels.dart';
import '../../logic/lagos_time.dart';
import '../../logic/money.dart';
import '../../logic/spending_controller.dart';
import '../app/app_scope.dart';
import '../app/router.dart';
import '../theme/app_theme.dart';
import '../widgets/expense_row.dart';
import '../widgets/spend_bar_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spending = AppScope.spendingOf(context);
    final auth = AppScope.of(context).auth;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('home.addExpense'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => context.go(Routes.addExpense),
        icon: const Icon(Icons.add),
        label: const Text('Add expense', style: AppTextStyles.button),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          // Auth too: linking a guest keeps the uid, so only the user's
          // name and guest flag change.
          listenable: Listenable.merge([spending, auth]),
          builder: (context, _) {
            if (spending.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _HomeBody(spending: spending, user: auth.user);
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.spending, required this.user});

  final SpendingController spending;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final week = spending.week;
    final recent = spending.recent;
    final today = LagosDay.of(spending.now);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.lg,
            0,
          ),
          sliver: SliverList.list(
            children: [
              _Header(greeting: greeting(spending.now), user: user),
              if (spending.loadError case final error?) ...[
                const SizedBox(height: AppSpacing.md),
                Text(error, style: TextStyle(color: palette.dangerText)),
              ],
              const SizedBox(height: AppSpacing.lg),
              _WeekCard(
                totalKobo: week.totalKobo,
                dailyAverageKobo: week.dailyAverageKobo,
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spend per day', style: AppTextStyles.bodyStrong),
                      const SizedBox(height: AppSpacing.lg),
                      SpendBarChart(week: week),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Recent', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
        SliverPadding(
          // Room for the Add expense button so it never covers a row.
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            96,
          ),
          sliver: SliverToBoxAdapter(
            child: recent.isEmpty
                ? const _EmptyRecent()
                : Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (final (i, e) in recent.indexed) ...[
                          if (i > 0) const Divider(),
                          ExpenseRow(
                            key: ValueKey(e.id),
                            expense: e,
                            today: today,
                            onDelete: () => _delete(context, e),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _delete(BuildContext context, Expense expense) {
    spending.deleteExpense(expense);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted ${expense.title}'),
          action: SnackBarAction(
            key: const Key('home.undoDelete'),
            label: 'Undo',
            onPressed: () => spending.restoreExpense(expense),
          ),
        ),
      );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.user});

  final String greeting;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTextStyles.body.copyWith(color: palette.bodyText),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Your money', style: AppTextStyles.h2),
            ],
          ),
        ),
        _AccountButton(user: user),
      ],
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({required this.user});

  final AppUser? user;

  String get _initials {
    final name = user?.displayName?.trim() ?? '';
    if (user?.isGuest ?? true) return 'G';
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    return [
      parts.first,
      if (parts.length > 1) parts.last,
    ].map((p) => p.characters.first.toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Account',
      excludeSemantics: true,
      child: InkWell(
        key: const Key('home.account'),
        customBorder: const CircleBorder(),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => _AccountSheet(user: user),
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: scheme.primaryContainer,
          child: Text(
            _initials,
            style: AppTextStyles.monogram.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountSheet extends StatelessWidget {
  const _AccountSheet({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    final isGuest = user?.isGuest ?? true;
    return SafeArea(
      child: Padding(
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
            Text(
              isGuest
                  ? 'You are using a guest account'
                  : user!.displayName ?? '',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (isGuest) ...[
              Text(
                'Sign in with Google to keep your spending if you lose or '
                'change your phone.',
                style: AppTextStyles.small,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                key: const Key('account.linkGoogle'),
                onPressed: () {
                  Navigator.pop(context);
                  auth.signInWithGoogle();
                },
                child: const Text('Sign in with Google'),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'If you sign out of a guest account, its spending can\'t be '
                'recovered.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            OutlinedButton(
              key: const Key('account.signOut'),
              onPressed: () {
                Navigator.pop(context);
                auth.signOut();
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.totalKobo, required this.dailyAverageKobo});

  final int totalKobo;
  final int dailyAverageKobo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Spent this week', style: AppTextStyles.title),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Text(
                  '7 days',
                  style: AppTextStyles.captionStrong.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              formatNaira(totalKobo),
              style: AppTextStyles.amountHero,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Daily average ${formatNaira(dailyAverageKobo)}',
            style: AppTextStyles.small.copyWith(color: palette.bodyText),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          'No expenses yet. Tap Add expense to log your first one.',
          textAlign: TextAlign.center,
          style: AppTextStyles.small.copyWith(
            color: AppPalette.of(context).bodyText,
          ),
        ),
      ),
    );
  }
}
