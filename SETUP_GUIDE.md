# SmartFarm Hub - Complete Setup Guide

This guide will walk you through setting up SmartFarm Hub from scratch.

---

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- [ ] Flutter SDK 3.0+ installed
- [ ] Android Studio or Xcode (for mobile development)
- [ ] Firebase account (free tier is sufficient)
- [ ] OpenWeatherMap API key (free tier: 1000 calls/day)
- [ ] Google Gemini API key (free tier available)
- [ ] Git installed

---

## 🔥 Firebase Setup (Step-by-Step)

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `smartfarm-hub`
4. Disable Google Analytics (optional)
5. Click **"Create project"**

### 2. Add Android App to Firebase

1. Click the **Android icon** on Firebase project dashboard
2. Enter Android package name: `com.smartfarm.hub`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### 3. Add iOS App to Firebase (Optional)

1. Click the **iOS icon**
2. Enter iOS bundle ID: `com.smartfarm.hub`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

### 4. Enable Firebase Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Click **Save**

### 5. Create Firestore Database

1. Go to **Firestore Database** → **Create database**
2. Select **"Start in production mode"**
3. Choose a location (preferably near your users)
4. Click **Enable**

### 6. Add Firestore Security Rules

Go to **Firestore Database** → **Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /crops/{cropId} {
      allow read, write: if request.auth != null;
    }
    match /tasks/{taskId} {
      allow read, write: if request.auth != null;
    }
    match /disease_history/{recordId} {
      allow read, write: if request.auth != null;
    }
    match /knowledge/{articleId} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

Click **Publish**.

### 7. Enable Firebase Storage

1. Go to **Storage** → **Get started**
2. Start in **production mode**
3. Choose same location as Firestore
4. Click **Done**

### 8. Add Storage Security Rules

Go to **Storage** → **Rules** and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /crop_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /disease_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /profile_images/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Click **Publish**.

---

## 🌤️ OpenWeatherMap API Setup

1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Click **"Sign Up"** (free account)
3. Verify your email
4. Go to **API keys** tab
5. Copy your API key
6. Add to `.env` file:
   ```
   WEATHER_API_KEY=your_key_here
   ```

---

## 🤖 Google Gemini API Setup

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with Google account
3. Click **"Get API key"**
4. Create a new API key
5. Copy the key
6. Add to `.env` file:
   ```
   GEMINI_API_KEY=your_key_here
   ```

---

## 🚀 Flutter Project Setup

### 1. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 2. Configure Firebase for Flutter

```bash
cd SmartFarm-Hub
flutterfire configure
```

Select your Firebase project and platforms (Android/iOS).

This generates `lib/firebase_options.dart` automatically.

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Verify Setup

Check that these files exist:
- `android/app/google-services.json` ✅
- `ios/Runner/GoogleService-Info.plist` (if using iOS) ✅
- `lib/firebase_options.dart` ✅
- `.env` with API keys ✅

---

## 🎨 Add Plant Disease Model (Optional)

### Option 1: Use Demo Mode
The app works without a model using demo results.

### Option 2: Add Real Model

1. Download a PlantVillage TFLite model
2. Place it in: `assets/models/plant_disease.tflite`
3. Ensure `pubspec.yaml` includes:
   ```yaml
   assets:
     - assets/models/
   ```

---

## ▶️ Running the App

### Android

```bash
flutter run -d android
```

### iOS

```bash
flutter run -d ios
```

### Troubleshooting

**"No devices found"**
- Ensure USB debugging is enabled (Android)
- Run `flutter devices` to check

**"Firebase initialization failed"**
- Verify `google-services.json` is in correct location
- Run `flutterfire configure` again

**"API key error"**
- Check `.env` file exists in project root
- Ensure no extra spaces in API keys

---

## 📦 Building Release APK

```bash
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🎉 First Launch Checklist

After launching the app:

1. [ ] Register a new account
2. [ ] Complete profile setup
3. [ ] Test weather fetching
4. [ ] Add a test crop
5. [ ] Create a farming task
6. [ ] Test AI chatbot
7. [ ] Browse knowledge articles
8. [ ] Try disease detection (with/without model)

---

## 🆘 Common Issues

### Build Errors

**Gradle sync failed**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Multidex error**
- Already handled in `build.gradle` with `multiDexEnabled true`

### Runtime Errors

**Weather not loading**
- Check internet connection
- Verify API key in `.env`
- Enable location permissions

**Chatbot not responding**
- Verify Gemini API key
- Check internet connection

**Images not uploading**
- Enable storage permissions
- Check Firebase Storage rules

---

## ✅ Production Deployment Checklist

Before deploying to production:

- [ ] Change Firebase to production mode
- [ ] Add proper app signing (Android keystore)
- [ ] Update app version in `pubspec.yaml`
- [ ] Test on multiple devices
- [ ] Add crash analytics (Firebase Crashlytics)
- [ ] Review and tighten security rules
- [ ] Set up CI/CD pipeline (optional)
- [ ] Prepare Play Store/App Store assets

---

## 📞 Support

For issues:
1. Check this guide
2. Review README.md
3. Check Firebase Console logs
4. Review Flutter logs: `flutter logs`

---

**You're all set! Happy farming! 🌱🚜**
