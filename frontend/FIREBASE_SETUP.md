# Firebase Setup Guide for MentorTrack

## Step-by-Step Firebase Configuration

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "MentorTrack" (or your preferred name)
4. Follow the setup wizard
5. Enable Google Analytics (optional)

### 2. Enable Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Email/Password** provider
3. Click "Save"

### 3. Create Firestore Database

1. Go to **Firestore Database** > **Create database**
2. Start in **test mode** (for development)
3. Choose your preferred location
4. Click "Enable"

### 4. Enable Storage

1. Go to **Storage** > **Get started**
2. Start in **test mode** (for development)
3. Choose your preferred location
4. Click "Done"

### 5. Android Configuration

1. In Firebase Console, click the Android icon
2. Register your app:
   - Package name: `com.example.cse_mentorship_app` (check your `android/app/build.gradle` for actual package name)
   - App nickname: MentorTrack Android
   - Debug signing certificate SHA-1 (optional for now)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`
5. Make sure `android/app/build.gradle` includes:
   ```gradle
   dependencies {
       // ... other dependencies
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
6. Make sure `android/app/build.gradle` includes at the bottom:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### 6. iOS Configuration (if needed)

1. In Firebase Console, click the iOS icon
2. Register your app:
   - Bundle ID: Check your `ios/Runner.xcodeproj` for actual bundle ID
   - App nickname: MentorTrack iOS
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` in Xcode
6. Drag `GoogleService-Info.plist` into the Runner folder

### 7. Firestore Security Rules (Development)

For development, use these rules (NOT for production):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 8. Storage Security Rules (Development)

For development, use these rules (NOT for production):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Testing the Setup

1. Run `flutter pub get`
2. Run `flutter run`
3. Try signing up a new user
4. Check Firebase Console to verify:
   - User appears in Authentication
   - Data appears in Firestore

## Troubleshooting

### Error: "FirebaseApp not initialized"
- Make sure `google-services.json` is in the correct location
- Run `flutter clean` and `flutter pub get`
- Restart your IDE

### Error: "MissingPluginException"
- Run `flutter clean`
- Delete `build/` folder
- Run `flutter pub get`
- Restart the app

### Authentication not working
- Verify Email/Password is enabled in Firebase Console
- Check that `google-services.json` is correctly placed
- Verify package name matches Firebase project

## Production Considerations

Before deploying to production:

1. **Update Security Rules**: Implement proper role-based access control
2. **Enable App Check**: Protect your backend resources
3. **Set up proper error handling**: Handle network failures gracefully
4. **Add data validation**: Validate data on both client and server
5. **Set up monitoring**: Use Firebase Crashlytics and Analytics
