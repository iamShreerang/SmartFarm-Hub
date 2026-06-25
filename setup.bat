@echo off
echo ========================================
echo SmartFarm Hub - Quick Setup for Windows
echo ========================================
echo.

REM Check if Android Studio is installed in common locations
set ANDROID_HOME=
if exist "C:\Users\%USERNAME%\AppData\Local\Android\Sdk" (
    set ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
    echo Found Android SDK at: %ANDROID_HOME%
    goto :configure
)

if exist "C:\Android\Sdk" (
    set ANDROID_HOME=C:\Android\Sdk
    echo Found Android SDK at: %ANDROID_HOME%
    goto :configure
)

if exist "%LOCALAPPDATA%\Android\Sdk" (
    set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
    echo Found Android SDK at: %ANDROID_HOME%
    goto :configure
)

echo.
echo [ERROR] Android SDK not found!
echo.
echo Please install Android Studio from:
echo https://developer.android.com/studio
echo.
echo After installation:
echo 1. Open Android Studio
echo 2. Go to Tools ^> SDK Manager
echo 3. Install Android SDK (API 34 recommended)
echo 4. Run this script again
echo.
pause
exit /b 1

:configure
echo.
echo Configuring Flutter to use Android SDK...
flutter config --android-sdk %ANDROID_HOME%

echo.
echo Installing Flutter dependencies...
flutter pub get

echo.
echo Running Flutter doctor...
flutter doctor

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Connect Android device (USB debugging enabled)
echo    OR
echo    Launch Android Emulator from Android Studio
echo.
echo 2. Setup Firebase:
echo    - Run: dart pub global activate flutterfire_cli
echo    - Run: flutterfire configure
echo    - Add google-services.json to android/app/
echo.
echo 3. Add API keys to .env file:
echo    WEATHER_API_KEY=your_key
echo    GEMINI_API_KEY=your_key
echo.
echo 4. Run the app:
echo    flutter run
echo.
pause
