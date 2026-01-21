# InstaDAM

Mini Instagram-like Flutter app built for the course exercise.

What this repo includes (high level)
- Provider-based state management (`AppProvider`).
- Local persistence: `SharedPreferences` (`StorageService`) and `sqflite` (+ `sqflite_common_ffi` for desktop) in `DbService`.
- Features: login/register, feed, create posts, per-user likes, comments, profile and settings.
- Export/import DB to/from JSON (`insta_export.json` in Documents).

Run locally

1. Install Flutter and ensure `flutter` is on PATH.
2. From project root:

```bash
flutter pub get
flutter run -d windows  # or -d <device>
```

Tests

Run widget/unit tests with:

```bash
flutter test
```

CI

This repo includes a basic GitHub Actions workflow that runs `flutter analyze` and `flutter test` on pushes and PRs.

Notes

- Default seeded users: `derek` / `admin` and `pau` / `admin`.
- Export file path (from app): Documents/insta_export.json
# instadam

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
