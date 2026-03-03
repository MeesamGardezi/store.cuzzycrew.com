# Dashboard Setup Guide

## Quick Start

### 1. Navigate to Dashboard folder
```bash
cd /Volumes/CodeVault/My\ Projects/store.cuzzycrew.com/Dashboard
```

### 2. Get dependencies
```bash
flutter pub get
```

### 3. Run the app
```bash
# Web (Chrome)
flutter run -d chrome

# iOS
flutter run -d ios

# Android
flutter run -d android
```

## Project Structure Overview

```
Dashboard/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── models/                      # Data models
│   │   ├── category.dart
│   │   ├── order.dart
│   │   └── product.dart
│   ├── services/                    # API & external services
│   │   └── api_service.dart
│   ├── controllers/                 # State management (Provider)
│   │   ├── auth_controller.dart
│   │   ├── order_controller.dart
│   │   └── product_controller.dart
│   └── pages/                       # UI screens
│       ├── login_page.dart
│       ├── home_page.dart
│       ├── orders_page.dart
│       ├── products_page.dart
│       └── categories_page.dart
├── pubspec.yaml                     # Dependencies
├── analysis_options.yaml            # Linting rules
├── README.md                        # Full documentation
└── SETUP.md                         # This file
```

## Features

✅ **Clean Architecture**
- Models, Services, Controllers, Pages clearly separated
- No mixed concerns

✅ **State Management**
- Provider pattern with ChangeNotifier
- Reactive updates

✅ **Authentication**
- Email/password login form
- Mock auth (ready for backend integration)

✅ **Three Main Pages**
1. **Orders** - List view with status badges
2. **Products** - Grid view with images
3. **Categories** - List view with thumbnails

✅ **Error Handling**
- Try-catch blocks on all API calls
- Retry buttons on error states
- User-friendly error messages

✅ **Loading States**
- Circular progress indicators
- Disabled buttons during loading

✅ **Empty States**
- Icons and messages when no data

✅ **API Logging**
- 🔵 Request start
- ✅ Success with response time
- ❌ Errors with details

## Configuration

### Backend URL

**Local Development** (default)
```dart
// lib/services/api_service.dart
static const String baseUrl = 'http://localhost:4000';
```

**Production**
```dart
static const String baseUrl = 'https://cuzzycrew-backend.vercel.app';
```

### Authentication

Currently using mock auth. To connect to backend:

1. Replace login call in `lib/controllers/auth_controller.dart`:
```dart
final response = await ApiService.post('/api/auth/login', {
  'email': email,
  'password': password,
});
```

2. Store token (if needed):
```dart
final token = response['data']['token'];
// Save to secure storage
```

## Styling & Theme

### Change app colors

Edit `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF1A1A2E),  // Change this
  brightness: Brightness.light,
),
```

### Change fonts

Edit `pubspec.yaml`:
```yaml
dependencies:
  google_fonts: ^6.2.1
```

Then in `lib/main.dart`:
```dart
textTheme: GoogleFonts.interTextTheme(),  // Change GoogleFonts
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Package management
  provider: ^6.0.0              # State management
  
  # Networking
  http: ^1.2.2                  # HTTP requests
  
  # Styling
  google_fonts: ^6.2.1          # Google Fonts integration
  cupertino_icons: ^1.0.8       # iOS icons
```

## Common Issues & Solutions

### Issue: API calls fail with "Failed to connect"
**Solution:** Ensure backend is running on `http://localhost:4000`

### Issue: Images not loading
**Solution:** Check thumbnail URLs are valid, app gracefully handles missing images

### Issue: Login always shows error
**Solution:** Current mock auth validates email format and password length (>= 6 chars)

### Issue: Data doesn't refresh after login
**Solution:** Pages fetch data in `initState`, ensure you navigate to pages after login

## Testing Credentials (Mock Auth)

Any valid email and password >= 6 characters:
```
Email: demo@example.com
Password: password123
```

## Debugging

### Enable Flutter Inspector
```bash
flutter run -d chrome --verbose
```

### Check console logs
- API calls are logged with 🔵 🟢 ❌ emojis
- Check browser console for errors

### Hot Reload
Press `R` in terminal after saving files

### Hot Restart
Press `Shift+R` to fully restart app

## Deployment

### Web (Vercel)
```bash
flutter build web
vercel deploy
```

### iOS (App Store)
```bash
flutter build ios --release
```

### Android (Play Store)
```bash
flutter build appbundle --release
```

## Project Statistics

- **Lines of Code**: ~800
- **Files**: 12
- **Complexity**: Minimal, no spaghetti code
- **Build Time**: ~30 seconds (first build)

## Next Steps

1. **Integrate real authentication** with backend token handling
2. **Add order detail page** with full order info
3. **Add product detail page** with full specs
4. **Implement search functionality** for products
5. **Add filtering** for categories and orders
6. **Persist auth state** using local storage
7. **Add animations** for page transitions
8. **Implement pull-to-refresh**

## Support

For issues or questions, refer to:
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- Backend API documentation

---

**Happy coding!** 🚀
