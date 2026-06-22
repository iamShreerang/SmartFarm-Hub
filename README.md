# SmartFarm Hub 🌱

**Your Complete Digital Farming Assistant**

SmartFarm Hub is a production-ready Flutter mobile application that empowers farmers with AI-powered crop management, real-time weather intelligence, plant disease detection, farming calendar, knowledge base, and an AI chatbot assistant.

---

## 🚀 Features

### ✅ Complete Authentication System
- Email/Password registration and login
- Password reset functionality
- Persistent login sessions
- Secure Firestore user profiles

### 📊 Farmer Dashboard
- Personalized welcome with real-time weather
- Crop status overview with growth progress
- Upcoming farming tasks
- Quick action buttons for major features

### 🌾 Crop Management (CRUD)
- Add, edit, and delete crops
- Track planting dates, harvest dates, and growth stages
- Upload and manage crop images (Firebase Storage)
- Growth progress visualization
- Swipe-to-delete functionality

### 🌤️ Weather Intelligence
- Real-time weather from OpenWeatherMap API
- 7-day forecast
- Temperature, humidity, wind speed, rain probability
- **Smart farming advice** based on weather conditions

### 🔬 AI Plant Disease Detection
- Camera and gallery image capture
- TensorFlow Lite model integration (38+ plant diseases)
- Disease identification with confidence scores
- Causes, prevention methods, and treatment suggestions
- Detection history tracking

### 📅 Farming Calendar & Reminders
- Visual calendar with task markers
- Create farming tasks (watering, fertilization, pesticide, harvesting, etc.)
- Local notifications for task reminders
- Task completion tracking
- Link tasks to specific crops

### 📚 Agriculture Knowledge Center
- Browse articles by category (Crop Guides, Fertilizers, Pest Management, Seasonal)
- Dynamic content from Firestore
- Searchable and filterable knowledge base

### 🤖 AI Chatbot Farming Assistant
- Powered by Google Gemini API
- Answers farming questions in real-time
- Contextual conversation history
- Agricultural expert knowledge

### 👤 User Profile Management
- Edit farmer details (name, age, location, farm size, farming type)
- Profile picture support
- Settings and logout

---

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.x (Dart)
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **State Management**: Provider
- **AI/ML**: TensorFlow Lite (plant disease detection)
- **APIs**: OpenWeatherMap (weather), Google Gemini (chatbot)
- **UI**: Material Design 3, Google Fonts, Custom Theme

---

## 📁 Project Structure

```
lib/
├── models/               # Data models (Crop, Task, Weather, Disease, etc.)
├── services/             # Firebase, API, and business logic services
├── providers/            # State management with Provider
├── screens/              # UI screens organized by feature
│   ├── auth/
│   ├── dashboard/
│   ├── crops/
│   ├── weather/
│   ├── disease/
│   ├── calendar/
│   ├── knowledge/
│   ├── chatbot/
│   └── profile/
├── widgets/              # Reusable UI components
├── utils/                # Constants, themes, helpers
├── firebase_options.dart # Firebase configuration
└── main.dart             # App entry point

assets/
├── images/               # App images and icons
├── models/               # TFLite model files (add your model here)
└── fonts/                # Custom fonts (Poppins)
```

---

## 🔧 Setup Instructions

### Prerequisites

- Flutter SDK (3.0+): [Install Flutter](https://docs.flutter.dev/get-started/install)
- Firebase CLI: `npm install -g firebase-tools`
- Android Studio / Xcode (for mobile development)
- Valid API keys for OpenWeatherMap and Google Gemini

### Step 1: Clone the Repository

```bash
cd SmartFarm-Hub
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Firebase Setup

1. **Create a Firebase project**: [Firebase Console](https://console.firebase.google.com/)

2. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

3. **Configure Firebase**:
   ```bash
   flutterfire configure
   ```
   This will generate `firebase_options.dart` automatically.

4. **Enable Firebase services**:
   - **Authentication**: Enable Email/Password
   - **Firestore Database**: Create database in production mode
   - **Storage**: Enable Firebase Storage
   - **Cloud Messaging**: Enable FCM (optional for push notifications)

5. **Add Firestore Security Rules**:
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

6. **Add Storage Security Rules**:
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

### Step 4: API Keys Configuration

1. Open `.env` file in the root directory
2. Add your API keys:
   ```
   WEATHER_API_KEY=your_openweathermap_api_key_here
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

**Get API Keys:**
- **OpenWeatherMap**: [Sign up here](https://openweathermap.org/api)
- **Google Gemini**: [Get API key](https://makersuite.google.com/app/apikey)

### Step 5: Add TensorFlow Lite Model (Optional)

1. Download a plant disease detection model (PlantVillage dataset recommended)
2. Place the `.tflite` file in `assets/models/plant_disease.tflite`
3. Update `pubspec.yaml` if needed

**Note**: The app includes a fallback demo mode if the model is not loaded.

### Step 6: Run the App

```bash
flutter run
```

For specific platforms:
```bash
flutter run -d android
flutter run -d ios
```

---

## 📱 Build for Release

### Android APK

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Google Play)

```bash
flutter build appbundle --release
```

Bundle location: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

Then open Xcode and archive for App Store.

---

## 🧪 Testing

### Run unit tests:
```bash
flutter test
```

### Run widget tests:
```bash
flutter test test/widget_test.dart
```

---

## 🗄️ Firestore Database Structure

```
users/
  {userId}/
    - name, email, age, location, farmSize, farmingType, profileImageUrl, createdAt

crops/
  {cropId}/
    - userId, name, plantingDate, expectedHarvestDate, growthStage, notes, imageUrls, location, areaSize, createdAt, updatedAt

tasks/
  {taskId}/
    - userId, title, description, type, status, scheduledDate, cropId, cropName, notificationEnabled, createdAt

disease_history/
  {recordId}/
    - userId, imageUrl, result{diseaseName, confidence, description, causes, prevention, treatments}, detectedAt

knowledge/
  {articleId}/
    - title, summary, content, category, imageUrl, tags, publishedAt
```

---

## 🔐 Security Best Practices

- ✅ API keys stored in `.env` (never commit to Git)
- ✅ Firebase security rules configured
- ✅ User authentication required for all operations
- ✅ Image compression before upload
- ✅ Input validation on all forms
- ✅ Error handling throughout the app

---

## 🚧 Troubleshooting

**Issue**: Firebase not initializing
- **Fix**: Run `flutterfire configure` again and ensure `firebase_options.dart` exists

**Issue**: Weather API not working
- **Fix**: Verify your OpenWeatherMap API key is active and added to `.env`

**Issue**: Gemini chatbot failing
- **Fix**: Check your Gemini API key and ensure it's enabled

**Issue**: TFLite model error
- **Fix**: Ensure `plant_disease.tflite` exists in `assets/models/` or use the demo mode

**Issue**: Build fails on Android
- **Fix**: Update Android SDK to 34, ensure `google-services.json` is in `android/app/`

---

## 📈 Future Enhancements

- [ ] Market price tracking for crops
- [ ] Community forum for farmers
- [ ] Livestock management module
- [ ] Soil health monitoring integration
- [ ] IoT sensor integration
- [ ] Multi-language support
- [ ] Offline mode with local database
- [ ] Export farming reports as PDF

---

## 📄 License

MIT License - feel free to use this project for learning and commercial purposes.

---

## 👨‍💻 Author

**SmartFarm Hub Development Team**

For support or contributions, please open an issue or pull request.

---

## 🙏 Acknowledgments

- Firebase for backend infrastructure
- OpenWeatherMap for weather data
- Google Gemini for AI chat capabilities
- TensorFlow for ML model support
- Flutter community for amazing packages

---

**Happy Farming! 🌾🚜**
