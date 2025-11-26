# Hayırhah - Prayer Times App

A beautiful, minimal prayer times application built with Flutter, featuring Turkish Diyanet calculation method and a 7-day forecast.

## Features

### 🕌 Prayer Times
- **Accurate Times**: Uses Aladhan API with Diyanet İşleri Başkanlığı calculation method (Method 13)
- **Real-time Countdown**: Live countdown to the next prayer time
- **Today's Schedule**: Horizontal view of all 6 daily prayer times (İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı)
- **7-Day Forecast**: Complete prayer times for the upcoming week

### 🌍 Location
- **IP-based Detection**: Automatic location detection via IP address
- **Manual Selection**: Change location by selecting city and country
- **No GPS Required**: No location permissions needed

### 🇹🇷 Turkish Localization
- Full Turkish UI
- Turkish date formatting (e.g., "Çarşamba, 26 Kasım")
- Turkish prayer names

### 🎨 Beautiful Design
- Modern gradient UI with deep indigo theme
- Smooth animations and transitions
- Responsive layout
- Tabular figures for stable countdown timer
- Minimalist crescent moon app icon

## Screenshots

*Add screenshots here*

## Installation

### Prerequisites
- Flutter SDK (>=3.9.2)
- iOS development setup (for iOS deployment)
- Android development setup (for Android deployment)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd hayirhah
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Technical Stack

### Framework
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language

### Dependencies
- `http`: API requests
- `intl`: Date/time formatting and localization
- `google_fonts`: Outfit font family
- `geocoding`: Reverse geocoding (optional)
- `flutter_localizations`: Turkish localization support
- `flutter_launcher_icons`: Icon generation

### API
- **Aladhan API**: Prayer times calculation
  - Calendar endpoint: `http://api.aladhan.com/v1/calendar`
  - Method 13: Diyanet İşleri Başkanlığı, Turkey
- **IP API**: Location detection
  - Endpoint: `http://ip-api.com/json`

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── prayer_model.dart    # Prayer times data model
├── services/
│   └── prayer_service.dart  # API service layer
└── screens/
    └── home_screen.dart     # Main UI screen
```

## Features Breakdown

### Data Layer
- **PrayerService**: Handles API communication
  - `getLocationFromIP()`: Detects user location
  - `getCalendarTimes()`: Fetches monthly prayer times
- **PrayerTimes**: Model class for prayer time data

### UI Components
- **Header**: Location, date, and countdown timer
- **Today View**: Horizontal list of current day's prayer times
- **Forecast List**: 7-day prayer times with column headers
- **Location Dialog**: Manual city/country selection

## Customization

### Changing Calculation Method
Edit `prayer_service.dart`:
```dart
static const int _method = 13; // Change to desired method
```

Available methods can be found in [Aladhan API documentation](https://aladhan.com/prayer-times-api#GetCalendar).

### Theme Colors
Edit `main.dart` and `home_screen.dart` gradient colors:
```dart
colors: [
  Color(0xFF1A237E), // Deep Indigo
  Color(0xFF3949AB), // Lighter Indigo
  Color(0xFF8C9EFF), // Accent Blue
],
```

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## App Icon
The app uses a minimal crescent moon design on a deep indigo background. To regenerate icons:

```bash
flutter pub run flutter_launcher_icons
```

Icon configuration is in `pubspec.yaml` under `flutter_launcher_icons`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Add your license here]

## Acknowledgments

- [Aladhan API](https://aladhan.com/) for prayer times data
- [ip-api.com](http://ip-api.com/) for location services
- Turkish Presidency of Religious Affairs (Diyanet) for calculation methodology

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

Made with ❤️ using Flutter
