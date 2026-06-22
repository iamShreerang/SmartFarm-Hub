# SmartFarm Hub - Deployment Guide

Complete guide to deploy SmartFarm Hub to Google Play Store and Apple App Store.

---

## 🤖 Android Deployment (Google Play Store)

### Step 1: Generate App Signing Key

```bash
keytool -genkey -v -keystore ~/smartfarm-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smartfarm
```

Enter password and details when prompted.

### Step 2: Configure Key Properties

Create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=smartfarm
storeFile=/path/to/smartfarm-keystore.jks
```

**Important**: Add `key.properties` to `.gitignore`!

### Step 3: Update build.gradle

Edit `android/app/build.gradle` (already configured in this project):

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Step 4: Build App Bundle

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Step 5: Prepare Play Store Assets

Create these assets:

1. **App Icon**: 512x512 PNG
2. **Feature Graphic**: 1024x500 PNG
3. **Screenshots**: At least 2 (phone + tablet)
4. **Privacy Policy URL**: Required if collecting data
5. **Short Description**: Max 80 characters
6. **Full Description**: Max 4000 characters

### Step 6: Google Play Console Setup

1. Go to [Google Play Console](https://play.google.com/console)
2. Create app → Enter app details
3. Upload app bundle (`.aab` file)
4. Fill in store listing
5. Set content rating
6. Set pricing & distribution
7. Submit for review

**Estimated Review Time**: 1-7 days

---

## 🍎 iOS Deployment (Apple App Store)

### Step 1: Apple Developer Account

- Enroll in [Apple Developer Program](https://developer.apple.com/) ($99/year)

### Step 2: Configure iOS App

Edit `ios/Runner/Info.plist` - add permissions:

```xml
<key>NSCameraUsageDescription</key>
<string>SmartFarm Hub needs camera access for plant disease detection</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>SmartFarm Hub needs photo access to analyze plant images</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>SmartFarm Hub needs location for weather information</string>
```

### Step 3: Create App ID in Apple Developer Portal

1. Go to [Apple Developer](https://developer.apple.com/)
2. Certificates, IDs & Profiles → Identifiers
3. Create App ID: `com.smartfarm.hub`
4. Enable capabilities (Push Notifications, etc.)

### Step 4: Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. My Apps → + → New App
3. Enter app information
4. Set bundle ID: `com.smartfarm.hub`

### Step 5: Build iOS Release

```bash
flutter build ios --release
```

### Step 6: Open Xcode and Archive

```bash
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Any iOS Device** as target
2. Product → Archive
3. Wait for archive to complete
4. Distribute App → App Store Connect
5. Upload

### Step 7: Prepare App Store Assets

1. **App Icon**: 1024x1024 PNG (no transparency)
2. **Screenshots**: iPhone (6.5", 5.5") + iPad
3. **App Preview Video**: Optional but recommended
4. **Description**: No character limit
5. **Keywords**: Comma-separated (max 100 chars)
6. **Privacy Policy URL**: Required

### Step 8: Submit for Review

1. Complete all app information
2. Add screenshots and metadata
3. Select pricing and availability
4. Submit for review

**Estimated Review Time**: 1-3 days

---

## 🔒 Pre-Deployment Security Checklist

- [ ] Remove all debug prints and logs
- [ ] Enable Firebase security rules
- [ ] Use environment variables for API keys
- [ ] Enable ProGuard/R8 obfuscation (Android)
- [ ] Test on multiple devices and OS versions
- [ ] Implement crash reporting (Firebase Crashlytics)
- [ ] Add analytics (Firebase Analytics)
- [ ] Test all payment flows (if applicable)
- [ ] Verify deep links work
- [ ] Test push notifications

---

## 📊 Post-Deployment Monitoring

### Firebase Crashlytics Setup

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_crashlytics: ^3.4.0
```

Add to `main.dart`:
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runApp(MyApp());
}
```

### Firebase Analytics

Already included in Firebase initialization. Track custom events:

```dart
FirebaseAnalytics.instance.logEvent(
  name: 'crop_added',
  parameters: {'crop_name': 'Tomato'},
);
```

---

## 🚀 Continuous Deployment (CI/CD)

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Play Store

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '11'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
      - run: flutter build appbundle --release
      - uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
          packageName: com.smartfarm.hub
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production
```

---

## 📈 Version Management

### Update Version

Edit `pubspec.yaml`:

```yaml
version: 1.0.1+2  # version+build_number
```

### Semantic Versioning

- **Major**: Breaking changes (2.0.0)
- **Minor**: New features (1.1.0)
- **Patch**: Bug fixes (1.0.1)

### Build Number

Increment for each release:
- 1.0.0+1
- 1.0.0+2 (hotfix)
- 1.1.0+3 (new features)

---

## 🐛 Testing Before Release

```bash
# Run all tests
flutter test

# Build and test release APK
flutter build apk --release
flutter install

# Check app size
flutter build apk --release --analyze-size

# Performance profiling
flutter run --profile
```

---

## 📝 Release Checklist

- [ ] All features tested on real devices
- [ ] No console errors or warnings
- [ ] Privacy policy and terms updated
- [ ] All third-party licenses included
- [ ] App icon and splash screen finalized
- [ ] Version number incremented
- [ ] Release notes prepared
- [ ] Beta testing completed (TestFlight/Play Console)
- [ ] Crash reporting enabled
- [ ] Analytics configured
- [ ] Backup and rollback plan ready

---

## 🎉 Congratulations!

Your SmartFarm Hub app is now live! 🌱

Monitor user feedback and iterate quickly. Good luck! 🚀
