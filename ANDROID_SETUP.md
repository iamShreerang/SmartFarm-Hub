# Android SDK Setup for SmartFarm Hub

## 🚨 Quick Fix

### Option 1: Install Android Studio (Recommended)

1. **Download Android Studio**
   - Visit: https://developer.android.com/studio
   - Download the latest version for Windows
   - Run the installer

2. **Complete Setup Wizard**
   - Launch Android Studio
   - Follow setup wizard
   - Install Android SDK (it will prompt you)
   - Install SDK Platform 34 (Android 14)
   - Install SDK Build-Tools 34.0.0

3. **Configure Flutter**
   ```bash
   flutter config --android-sdk C:\Users\YOUR_USERNAME\AppData\Local\Android\Sdk
   ```

4. **Verify**
   ```bash
   flutter doctor
   ```

### Option 2: Command Line SDK Tools Only

1. **Download SDK Command Line Tools**
   - Visit: https://developer.android.com/studio#command-tools
   - Download "Command line tools only"
   - Extract to `C:\Android\cmdline-tools`

2. **Set Environment Variables**
   ```
   ANDROID_HOME = C:\Android\Sdk
   Path += C:\Android\Sdk\platform-tools
   Path += C:\Android\Sdk\tools
   ```

3. **Install SDK Components**
   ```bash
   cd C:\Android\cmdline-tools\latest\bin
   sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```

4. **Configure Flutter**
   ```bash
   flutter config --android-sdk C:\Android\Sdk
   flutter doctor --android-licenses
   ```

---

## 🔍 Finding Your Android SDK

If you already have Android Studio installed, find SDK location:

1. Open Android Studio
2. File → Settings (or Ctrl+Alt+S)
3. Appearance & Behavior → System Settings → Android SDK
4. Copy the "Android SDK Location" path
5. Run:
   ```bash
   flutter config --android-sdk "YOUR_SDK_PATH"
   ```

---

## ✅ Verification Steps

After setup, run:

```bash
flutter doctor -v
```

You should see:
```
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
```

---

## 🎯 Complete Checklist

- [ ] Android Studio installed OR Command line tools installed
- [ ] Android SDK installed (API Level 34)
- [ ] Flutter configured with SDK path
- [ ] Android licenses accepted: `flutter doctor --android-licenses`
- [ ] Java JDK installed (bundled with Android Studio)
- [ ] Device connected OR Emulator running

---

## 📱 Create Android Emulator

1. Open Android Studio
2. Tools → Device Manager
3. Create Device → Select Phone (e.g., Pixel 7)
4. Download system image (API 34)
5. Launch emulator
6. Verify with: `flutter devices`

---

## 🚀 Running SmartFarm Hub

Once Android toolchain is ready:

```bash
cd c:\Users\dbda26\Downloads\SmartFarm-Hub

# Install dependencies
flutter pub get

# List available devices
flutter devices

# Run on connected device/emulator
flutter run
```

---

## 🐛 Common Issues

### "Android SDK not found"
```bash
# Set SDK path manually
flutter config --android-sdk "C:\Users\YOUR_USERNAME\AppData\Local\Android\Sdk"
```

### "Android licenses not accepted"
```bash
flutter doctor --android-licenses
# Press 'y' to accept all
```

### "Unable to locate Java"
- Install JDK 11 or 17 from: https://adoptium.net/
- Or use bundled JDK from Android Studio

### "Gradle build failed"
```bash
cd android
gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## ⚡ Quick Start Script

Run the provided `setup.bat`:

```bash
cd c:\Users\dbda26\Downloads\SmartFarm-Hub
setup.bat
```

This will automatically:
- Detect Android SDK
- Configure Flutter
- Install dependencies
- Run Flutter doctor

---

## 📞 Need Help?

After setup, if issues persist:

1. Check Flutter doctor: `flutter doctor -v`
2. Check devices: `flutter devices`
3. Check logs: `flutter run --verbose`
4. Refer to: https://docs.flutter.dev/get-started/install/windows

---

**Once Android toolchain shows [✓], you're ready to run SmartFarm Hub!** 🌱
