# bms

## Running this app

The canonical entry point is `lib/main.dart`.

Run the app with:

```bash
flutter run -t lib/main.dart
```

Legacy and preview launch files are intentionally disabled or moved out of
`lib/` so they do not become the default run target again. Please do not
re-enable them without asking first.

## Project Conventions

1. Never add a new standalone `main()` / `MaterialApp` inside `lib/screens/*`.
   If a screen needs isolated preview/testing, use a widget test in `test/` or
   a debug-only screen reachable from inside the real app guarded by
   `kDebugMode`.
2. Any future archived or legacy code must have its entry point disabled at the
   time it is archived, including renaming or removing its runnable `pubspec`
   and marking the main launcher as archived.
