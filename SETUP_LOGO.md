# Setup Logo TixCycle

## Logo sudah diintegrasikan di:
✅ Splash Screen (`lib/views/splash_screen.dart`)
✅ Login Page (`lib/views/login_page.dart`)
✅ Register Page (`lib/views/register_page.dart`)

## Untuk Generate App Icon/Launcher Icon:

### Langkah 1: Install Dependencies
```powershell
flutter pub get
```

### Langkah 2: Generate Launcher Icons
```powershell
flutter pub run flutter_launcher_icons
```

### Langkah 3: Clean dan Rebuild
```powershell
flutter clean
flutter pub get
```

### Langkah 4: Run Aplikasi
```powershell
flutter run
```

## Catatan Penting:

### Ukuran Logo yang Direkomendasikan:
- **Minimal**: 512x512 px
- **Optimal**: 1024x1024 px
- **Format**: PNG dengan background transparan

### Jika logo perlu disesuaikan:
1. Edit file `images/LOGO.png`
2. Pastikan ukuran minimal 512x512 px
3. Jalankan lagi: `flutter pub run flutter_launcher_icons`

### Konfigurasi (sudah diatur di pubspec.yaml):
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "images/LOGO.png"
  adaptive_icon_background: "#FFF8E2"  # Warna krem TixCycle
  adaptive_icon_foreground: "images/LOGO.png"
```

## Troubleshooting:

### Jika icon tidak muncul di Android:
1. Uninstall aplikasi dari device/emulator
2. Clean project: `flutter clean`
3. Rebuild: `flutter run`

### Jika icon tidak muncul di iOS:
1. Buka `ios/Runner.xcworkspace` di Xcode
2. Refresh assets
3. Clean build folder di Xcode
4. Rebuild dari Flutter

## Lokasi File Icon yang Dihasilkan:

### Android:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`

### iOS:
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Web (jika diperlukan):
- `web/icons/Icon-*.png`
- `web/favicon.png`
