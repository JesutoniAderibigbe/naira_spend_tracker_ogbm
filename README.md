# Naira Spend Tracker (OGBM build)

Another build of the Naira Spend Tracker spec. The app is the same: track
spending in ₦, set monthly budgets per category, view insights. This build
uses a **repository pattern** over Firestore and is themed from **Figma
component exports** stored in the repo.

## What's different in this build

- **Repository layer**: `AuthRepository`, `ExpenseRepository` and `BudgetRepository` interfaces, each with a Firebase or Firestore implementation. This keeps screens and logic testable with fakes.
- **Guest to account migration**: `UserDataCopier` moves a guest's expenses and budgets over when they sign in with Google.
- **App scope**: dependencies are passed down through `AppScope` instead of globals.
- **Hand-built chart**: the weekly spend chart is a custom widget, so there's no chart package dependency.
- **Naira input formatter**: amounts are formatted as you type.

## Layout

```text
lib/
  data/models/        Expense, Category, AppUser
  data/repositories/  interfaces + Firebase/Firestore implementations
  logic/              money, spending, budget status, validation, Lagos time
  ui/app/             app, router (go_router), home shell, app scope
  ui/screens/         sign in, home, add expense, budgets, insights
  ui/widgets/         budget card, expense row, progress track, chart
```

The design source lives in the repo root: `design-tokens.tokens.json` plus PNG
exports of each component (Bottom nav, Budget card, Category tile, Expense row,
Summary card).

## Getting started

```bash
fvm use
flutterfire configure   # generates lib/firebase_options.dart (git-ignored)
flutter pub get
flutter run
```

## Docs and tests

See `docs/SPEC.md` and `docs/DATA_MODEL.md`. Tests live in `test/data`,
`test/logic` and `test/ui`, with shared fakes in `test/helpers`. Run them with
`flutter test`.
