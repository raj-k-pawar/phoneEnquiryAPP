# Janki Agro Tourism - Flutter App

A complete phone enquiry management app for Janki Agro Tourism with Admin and Manager roles.

## Features

### Admin
- Dashboard with date-wise batch booking counts
- Manage Batches (Add / Edit / Delete)
- Manage Managers (Add / Edit / Delete with password)
- View All Customers by date with batch grouping

### Manager
- Dashboard with personal batch booking counts by date
- Booking Enquiry Form (Name, Phone, Date, Batch, Guests, Notes)
- View & Cancel own bookings

## Setup Instructions

### 1. Prerequisites
- Flutter SDK 3.0+
- Android Studio / VS Code with Flutter plugin
- Android SDK (for Android) or Xcode (for iOS)

### 2. Install Dependencies
```bash
cd janki_agro_tourism
flutter pub get
```

### 3. Run the App
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Release APK
flutter build apk --release

# Release iOS
flutter build ios --release
```

## Default Credentials
- **Admin:** `admin` / `admin123`
- Add managers via Admin → Manage Managers

## Project Structure
```
lib/
├── main.dart                     # Entry point + splash
├── models/
│   ├── user_model.dart
│   ├── batch_model.dart
│   └── booking_model.dart
├── services/
│   ├── database_service.dart     # SQLite (sqflite)
│   └── auth_provider.dart        # State management
├── utils/
│   └── app_theme.dart            # Theme + colors
├── widgets/
│   └── batch_summary_card.dart   # Shared widgets
└── screens/
    ├── login_screen.dart
    ├── admin/
    │   ├── admin_dashboard.dart
    │   ├── manage_batches_screen.dart
    │   ├── manage_managers_screen.dart
    │   └── all_customers_screen.dart
    └── manager/
        ├── manager_dashboard.dart
        ├── booking_enquiry_screen.dart
        └── manager_bookings_screen.dart
```

## Tech Stack
- **Flutter** (Dart)
- **SQLite** via `sqflite` - local database
- **Provider** - state management
- **table_calendar** - calendar widget
- **google_fonts** - Poppins font
- **shared_preferences** - session persistence
- **crypto** - password hashing (SHA-256)

## Default Batches (auto-created on first launch)
1. Morning Batch — 9:00 AM to 2:00 PM (capacity: 50)
2. Afternoon Batch — 3:00 PM to 8:00 PM (capacity: 50)
3. Full Day Batch — 10:00 AM to 5:00 PM (capacity: 30)

All batches and managers are fully configurable by the Admin.
