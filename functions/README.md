# Cloud Functions

The notification triggers write notification-bell records for the Civica app.

## Civica Chatbot school-demo mode

Civica calls Gemini directly from the client in school-demo mode. It does not
need Firebase Functions or Firebase Secret Manager. Supply a separate,
restricted demo key only at build/run time, never in source control:

```powershell
# Local web development
flutter run -d chrome --dart-define=GEMINI_API_KEY=YOUR_RESTRICTED_WEB_KEY

# Firebase Hosting web build
flutter build web --dart-define=GEMINI_API_KEY=YOUR_RESTRICTED_WEB_KEY

# Android APK build (use a different Android-restricted key)
flutter build apk --dart-define=GEMINI_API_KEY=YOUR_RESTRICTED_ANDROID_KEY --dart-define=GEMINI_ANDROID_CERT_SHA1=YOUR_SIGNING_CERT_SHA1
```

For PowerShell, prefer the included prompt-based scripts. They do not write the
key to source files or shell history:

```powershell
.\tools\build_civica_web.ps1 -Deploy
.\tools\build_civica_android.ps1
```

For a supervised school presentation only, add `-EnableDemoAdminBypass` to
either command. It makes the Civica house icon on the desktop sign-in screen
open the admin dashboard without Firebase authentication. Never use or deploy
that flag outside the demo.

The web key must be restricted to the Gemini API and the Firebase Hosting and
localhost referrers. The Android key must be restricted to this app's package
name (`com.example.bms`) and signing-certificate SHA-1. Obtain the fingerprint
for the currently configured Android signing key with:

```powershell
cd android
.\gradlew signingReport
cd ..
```

Client-side keys can be
extracted from a built application, so this mode is for a controlled school demo
only. Rotate/delete the keys after presentation.

# Civica notification delivery

The in-app notification bell is driven by Firestore. Push-notification services
are not configured in this project.
