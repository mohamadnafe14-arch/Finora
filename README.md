# Finora

Offline-first personal finance manager built with Flutter. Android and iOS are
the initial target platforms; all data is stored locally in SQLite.

## Architecture

- **MVVM:** Views (widgets) → ViewModels (Cubits) → Repositories → SQLite.
- **Feature-first:** each feature owns its `data/` (models, repositories, SQL)
  and `presentation/` (cubits, pages, widgets) folders. There is no separate
  Domain layer.
- **DI:** GetIt + Injectable. Call `configureDependencies()` once at startup.
  Generated `injection.config.dart` is committed; regenerate with
  `dart run build_runner build` after changing annotations.
- **Navigation:** centralized GoRouter configuration in `lib/app/router/`.
- **Database:** `AppDatabase` owns the single SQLite connection;
  `DatabaseMigrator` applies ordered schema migrations.

```
lib/
├── app/                 # app widget, router, theme
├── core/
│   ├── config/          # app configuration
│   ├── database/        # SQLite access and migrations
│   ├── di/              # GetIt / Injectable setup
│   └── utils/           # shared helpers
└── features/
    └── home/
        ├── data/        # models, repositories
        └── presentation/
            ├── cubit/   # ViewModels (Cubit)
            ├── pages/
            └── widgets/
```

## Conventions

- Clean Code and SOLID: small classes, single responsibility, abstractions at
  boundaries, constructor injection. No widget talks to SQL directly.
- **No Dart file may exceed 200 lines** (`tool/check_file_lengths.sh`).
- Commits use Conventional Commits: `feat:`, `fix:`, `chore:`, `ci:`, `docs:`.
- Each feature is developed on its own `feature/<name>` branch from `main`,
  pushed, then merged into `main` with `--no-ff` after checks pass.
- `main` is the stable branch; never force-push.

## Getting started

```bash
flutter pub get                        # install dependencies
dart run build_runner build            # regenerate DI config when needed
dart format --output=none --set-exit-if-changed .
flutter analyze
bash tool/check_file_lengths.sh
flutter test
flutter run                            # Android / iOS
```

## CI

`.github/workflows/ci.yml` runs formatting, static analysis, the 200-line guard,
and tests on every push to `main`/`feature/**` and on pull requests to `main`.

## License

BSD-3-Clause (Flutter template baseline).
