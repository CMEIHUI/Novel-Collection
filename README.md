# Novel Collection

Novel Collection is a cross-platform Flutter application for managing a personal novel library with favorites, reading progress, library filtering, statistics, and theme support.

## 🌟 What it does

This app helps users:
- Sign in and manage a personal novel collection
- Browse novels from a home dashboard
- View library entries and search/filter by title, author, genre, and rating
- Mark novels as favorites and access them in a dedicated Favorites tab
- Track reading progress and continue reading from a saved position
- View library analytics on the Statistics screen
- Add, edit, and delete novel records with cover image support

## 🧭 App structure

The bottom navigation shell provides these tabs:
- **Home** — dashboard, progress highlights, recommendations
- **Library** — full novel collection with filtering
- **Favorite** — favorite novels in one place
- **Statistics** — visual summary of library stats
- **Profile** — user profile and quick actions

## 🏗️ Project layout

- `lib/main.dart` — app entry point, theme switching, and launch routing
- `lib/screens/` — screens for login, home, library, favorites, statistics, profile, detail views, add/edit flows, and reader screens
- `lib/models/` — domain models for novel data and app entities
- `lib/database/` — platform-aware persistence with SQLite and web handling
- `lib/utils/` — helper utilities for filtering, stats, chart generation, and platform initialization
- `lib/services/` — authentication logic and service stubs
- `lib/widgets/` — reusable widgets and UI components

## ⚙️ Getting started

### Prerequisites
- Flutter SDK installed
- Android SDK or Xcode installed for mobile builds
- Desktop build tools for Windows, macOS, or Linux if needed

### Install dependencies

```bash
flutter pub get
```

### Run the app in debug mode

```bash
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

Generated APK location:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 📦 Main dependencies

- `flutter`
- `google_fonts`
- `sqflite`
- `sqflite_common_ffi`
- `file_picker`
- `image_picker`
- `shared_preferences`
- `fl_chart`

## 📝 Notes

- Desktop platforms initialize FFI support in `lib/main.dart`.
- Authentication is currently local/placeholder and can be extended to a backend.
- Database code is split between native and web-friendly implementations.

## 🧪 Testing

Run unit and widget tests with:

```bash
flutter test
```

## 🚀 Future improvements

- Add backend authentication and user syncing
- Enable import/export of novel collections
- Enhance analytics with historical trends and charts
- Improve UI polish and mobile responsiveness
