# bms

## Running this app

The canonical entry point is `lib/main.dart`.

Run the app with:

```bash
flutter run -t lib/main.dart
```

## Deploy to Firebase Hosting

The Firebase project is configured as `bms-system-2499a`. Install the Firebase
CLI and sign in once:

```bash
npm install -g firebase-tools
firebase login
```

In the Firebase Console, enable **Authentication > Sign-in method > Email/Password**.
Then build and deploy from the repository root:

```bash
flutter build web -t lib/main.dart
firebase deploy --only hosting,firestore,storage
```

Firebase will print a public URL such as
`https://bms-system-2499a.web.app`. The Hosting configuration serves the
Flutter output from `build/web` and supports browser route refreshes.

For a local network preview, use:

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Then open `http://<computer-ip>:8080` from another device on the same network.

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
