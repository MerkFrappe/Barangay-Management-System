# Cloud Functions

The announcement trigger creates an in-app notification for every `users` document whose `role` is `Resident`, then sends one OneSignal tag-targeted push.

Before deploying Functions, configure the secrets directly in your terminal:

```powershell
firebase functions:secrets:set ONESIGNAL_APP_ID --project bms-system-2499a
firebase functions:secrets:set ONESIGNAL_REST_API_KEY --project bms-system-2499a
```

The Flutter app must be built with the same OneSignal App ID so resident devices can be tagged:

```powershell
flutter build web --dart-define=ONESIGNAL_APP_ID=your-onesignal-app-id
flutter build apk --dart-define=ONESIGNAL_APP_ID=your-onesignal-app-id
```

Deploy the trigger after setting both secrets:

```powershell
firebase deploy --only functions --project bms-system-2499a
```
