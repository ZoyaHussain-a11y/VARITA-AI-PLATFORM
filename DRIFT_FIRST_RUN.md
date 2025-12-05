# First Run - Complete Setup Instructions

## Prerequisites

Ensure you have Flutter installed. Check with:
```bash
flutter --version
```

## Step-by-Step Setup

### 1. Navigate to Project Directory
```bash
cd path/to/your/project
```

### 2. Clean Previous Builds
```bash
flutter clean
```

### 3. Get Dependencies
```bash
flutter pub get
```

### 4. Generate Drift Database Code
This is CRITICAL - you must run this before the app will work:
```bash
flutter pub run build_runner build
```

If you encounter conflicts:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the App
```bash
flutter run
```

On web:
```bash
flutter run -d chrome
```

---

## What Happens on First Run

When the app starts:
1. **Database initialization**: Drift creates a SQLite database file
2. **Table creation**: All 8 tables are created automatically
3. **Data insertion**: Hardcoded doctors, specialties, and services are inserted
4. **UI loads**: App displays with all data from the database

**First run may take 5-10 seconds** due to database initialization.

---

## Verify Everything Works

1. **Splash Screen**: Should load normally
2. **Find Doctor Screen**: Should show 5 doctors from the database
3. **Doctor List**: Should be filterable by specialty
4. **Search**: Should search doctor names and specialties

---

## Troubleshooting

### Error: "app_database.g.dart not found"
**Solution**: Run build_runner:
```bash
flutter pub run build_runner build
```

### Error: "version conflict" or "pub get fails"
**Solution**: Clean and retry:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### App Crashes on Startup
**Solution**: Check log for specific error:
```bash
flutter run -v
```

### Database locked error
**Solution**: This shouldn't happen in development. If it does:
1. Uninstall the app
2. Run `flutter clean`
3. Run again

---

## After Setup

Your app now uses Drift completely:
- All data is persisted in a local SQLite database
- The database file is located in the app's document directory
- Data survives app restarts
- No hardcoded data in code anymore

---

## Next: Update Other Screens

To integrate Drift into other screens, follow the pattern in:
- `lib/screens/find_doctor_screen.dart` (already updated as example)
- `DRIFT_QUICK_REFERENCE.md` for code templates

---

## Database File Location

The database file is stored in:
- **Android**: `/data/data/com.example.my_flutter_app/app_flutter/databases/verita_app_db.sqlite`
- **iOS**: `/Applications/YourApp.app/Documents/app_flutter/databases/verita_app_db.sqlite`
- **Web**: IndexedDB (browser storage)

---

**Ready to start? Run the 5 steps above!**
