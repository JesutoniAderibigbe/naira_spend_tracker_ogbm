import 'package:flutter/material.dart';

import '../../logic/auth_controller.dart';
import '../app/app_scope.dart';
import '../theme/app_theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  AuthController? _auth;
  String? _shownError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = AppScope.of(context).auth;
    if (auth == _auth) return;
    _auth?.removeListener(_showError);
    _auth = auth..addListener(_showError);
  }

  void _showError() {
    final error = _auth?.error;
    if (error != null && error != _shownError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
    _shownError = error;
  }

  @override
  void dispose() {
    _auth?.removeListener(_showError);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _auth!,
          builder: (context, _) {
            final auth = _auth!;
            final busy = auth.isBusy;
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 52),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(
                                AppRadius.button,
                              ),
                            ),
                            child: Text(
                              '₦',
                              style: AppTextStyles.h1.copyWith(
                                color: scheme.onPrimary,
                              ),
                              semanticsLabel: 'Naira Spend Tracker',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        Text(
                          'Know where every naira goes.',
                          style: AppTextStyles.display,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Log spending in seconds, set monthly budgets, and '
                          'see your week at a glance.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: palette.bodyText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const _PreviewCard(),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.xxxl),
                        FilledButton.icon(
                          key: const Key('signIn.google'),
                          onPressed: busy ? null : auth.signInWithGoogle,
                          icon: const _GoogleMark(),
                          label: const Text('Continue with Google'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton(
                          key: const Key('signIn.guest'),
                          onPressed: busy ? null : auth.signInAsGuest,
                          child: const Text('Try it as a guest'),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Guest data stays on this phone until you sign in. '
                          'Signing in syncs it to your account.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: palette.bodyText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The illustrative "Spent this week" card. Sample data, so it is hidden
/// from screen readers.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  static const _bars = [0.08, 0.36, 0.2, 1.0, 0.12, 0.26, 0.3];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    return ExcludeSemantics(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Spent this week',
                      style: AppTextStyles.small.copyWith(
                        color: palette.bodyText,
                      ),
                    ),
                  ),
                  const Text('₦45,800', style: AppTextStyles.amountSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 56,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final (i, h) in _bars.indexed) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FractionallySizedBox(
                          heightFactor: h,
                          alignment: Alignment.bottomCenter,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: h == 1
                                  ? scheme.primary
                                  : palette.chartFaint,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A white disc with a "G", as in the design.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: Text(
        'G',
        style: AppTextStyles.smallStrong.copyWith(color: scheme.primary),
      ),
    );
  }
}
