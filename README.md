# TixCycle 🎫♻️

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)

> **Singkatnya:** Aplikasi mobile untuk pembelian dan manajemen tiket event/konser dengan konsep ramah lingkungan yang dibangun menggunakan Flutter dengan arsitektur GetX (MVC Pattern). 

---

## 📖 Deskripsi Proyek

TixCycle adalah aplikasi mobile yang memudahkan pengguna untuk menemukan, membeli, dan mengelola tiket event atau konser favorit mereka dengan cara yang modern dan ramah lingkungan.  Aplikasi ini mengintegrasikan sistem pemindaian QR code untuk validasi tiket dan menyediakan pengalaman pengguna yang seamless.

---

### 📲 Coba Aplikasi
[**Download APK (v1.0)**](https://drive.google.com/file/d/10RVtA2N-JX_wwKFUy89f4E4RdIlraUyt/view?usp=sharing)

---

### 👥 Tim Development

- **Reza Rasendriya Adi Putra** - [@reza675](https://github.com/reza675)
- **Waladi Lintang Novianto** - [@LintangNov](https://github.com/LintangNov)
- **Ikhsan Fillah Hidayat** - [@IkhsanFillah](https://github.com/IkhsanFillah) 

---

## ✨ Fitur Utama

* ✅ **Otentikasi Pengguna** - Login/Register dengan Firebase Authentication dan Google Sign-In
* ✅ **Pencarian & Filter Event** - Temukan event berdasarkan kategori dan preferensi
* ✅ **Pembelian Tiket** - Proses pembelian tiket yang mudah dan aman
* ✅ **E-Tiket dengan QR Code** - Tiket digital dengan QR code untuk validasi masuk
* ✅ **Scanner Tiket (Admin)** - Pemindaian dan validasi tiket menggunakan kamera
* ✅ **Manajemen Tiket** - Lihat dan kelola tiket yang telah dibeli
* ✅ **Detail Event** - Informasi lengkap mengenai event
* ✅ **Multi-Platform Support** - Support untuk Android, iOS, Web, Windows, Linux, dan macOS
* ✅ **Integrasi Lokasi** - Geolocator dan geocoding untuk menampilkan lokasi event
* ✅ **Share Tiket** - Bagikan tiket ke platform lain

---

## 🛠️ Tech Stack & Tools

Aplikasi ini dibuat dengan teknologi dan *best practice* berikut:

* **Framework:** Flutter SDK 3.6.1+ (Dart)
* **State Management:** GetX (Get 4.7.2)
* **Architecture:** MVC (Model-View-Controller)
* **Backend & Database:** 
  - Firebase (Authentication, Firestore, Storage)
  - Supabase
* **Local Storage:** Path Provider
* **Authentication:** Firebase Auth + Google Sign In
* **QR Code:** QR Flutter & Mobile Scanner
* **Location Services:** Geolocator + Geocoding
* **UI Components:** 
  - Carousel Slider
  - Image Picker
  - Custom Widgets
* **Other Tools:** 
  - Flutter DotEnv (Environment variables)
  - Intl (Internationalization - ID locale)
  - Permission Handler
  - Share Plus

---

## 🚀 Cara Menjalankan (Installation)

### Prerequisites

Pastikan Anda telah menginstal:
- Flutter SDK (versi 3.6. 1 atau lebih tinggi)
- Dart SDK
- Android Studio / VS Code
- Git
- Firebase CLI (optional, untuk konfigurasi Firebase)

### Langkah Instalasi

1. **Clone repository ini:**
   ```bash
   git clone https://github.com/reza675/TixCycle. git
   cd TixCycle
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Setup Environment Variables:**
   
   Buat file `.env` di root project dan tambahkan konfigurasi berikut:
   ```env
   SUPABASE_URL=your_supabase_url_here
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

4. **Setup Firebase:**
   
   - Pastikan file `firebase_options.dart` sudah dikonfigurasi dengan benar
   - Jika belum, jalankan Firebase CLI untuk setup:
   ```bash
   flutterfire configure
   ```

5. **Run aplikasi:**
   ```bash
   flutter run
   ```

   Atau untuk platform spesifik:
   ```bash
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   
   # Web
   flutter run -d chrome
   
   # Windows
   flutter run -d windows
   ```

---

## 📁 Struktur Proyek

```
lib/
├── bindings/          # Dependency injection bindings (GetX)
├── controllers/       # Business logic dan state management
├── models/           # Data models (Event, Transaction, User, dll)
├── repositories/     # Data layer untuk akses database
├── routes/           # Routing dan navigasi aplikasi
│   ├── app_pages.dart
│   └── app_routes.dart
├── services/         # Services (Firebase, API, dll)
├── views/            # UI screens dan widgets
│   ├── widgets/      # Reusable widgets
│   ├── beranda.dart
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── beli_tiket. dart
│   ├── detail_event.dart
│   ├── my_tickets_page. dart
│   ├── ticket_detail_page.dart
│   ├── scan_page. dart
│   ├── admin_ticket_scanner_page.dart
│   └── splash_screen.dart
├── firebase_options.dart
└── main.dart         # Entry point aplikasi
```

---

## 🎨 Screenshots & Fitur Detail

### Fitur Utama:

1. **Splash Screen** - Tampilan awal aplikasi dengan branding TixCycle
2. **Beranda** - Menampilkan event-event yang tersedia dengan carousel
3.  **Authentication** - Login & Register dengan email/password atau Google Sign-In
4. **Detail Event** - Informasi lengkap event termasuk lokasi, tanggal, dan harga
5. **Pembelian Tiket** - Flow pembelian tiket yang mudah
6. **My Tickets** - Daftar tiket yang telah dibeli dengan filter status
7. **E-Ticket** - Tiket digital dengan QR code dan tombol share
8. **Scanner** - Pemindaian QR code untuk validasi tiket (Admin)

---

## 🔑 Fitur Keamanan

- ✅ Firebase Authentication untuk keamanan user
- ✅ QR Code encryption untuk validasi tiket
- ✅ Permission handling untuk akses kamera dan lokasi
- ✅ Environment variables untuk API keys

---

## 📦 Dependencies Utama

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  get: ^4.7. 2
  
  # Firebase
  firebase_core: ^4. 1.1
  firebase_auth: ^6.1.0
  cloud_firestore: ^6.0.2
  firebase_storage: ^13.0.2
  
  # Supabase
  supabase_flutter: ^2.5.0
  
  # Authentication
  google_sign_in: ^7. 2.0
  
  # Location
  geolocator: ^14.0.2
  geocoding: ^4.0. 0
  
  # QR Code
  qr_flutter: ^4.1.0
  mobile_scanner: ^7.1.3
  
  # UI & Utils
  carousel_slider: ^4.2.1
  image_picker: ^1.0.7
  intl: ^0.18.1
  permission_handler: ^12.0. 1
  share_plus: ^7.2.2
  path_provider: ^2.1. 1
  flutter_dotenv: ^5.1.0
```

---

## 🎯 Roadmap & Future Features

- [ ] Push notifications untuk reminder event
- [ ] Payment gateway integration
- [ ] History transaksi
- [ ] Rating & review system
- [ ] Wishlist event
- [ ] Dark mode support
- [ ] Multi-language support

---

## 🤝 Contributing

Kontribusi selalu diterima dengan tangan terbuka! Berikut cara berkontribusi:

1. Fork repository ini
2. Buat feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

---

## 📝 License

Distributed under the MIT License.  See `LICENSE` for more information. 

---

## 📧 Kontak

Untuk pertanyaan atau saran, silakan hubungi tim development melalui:

- **Repository:** [https://github.com/reza675/TixCycle](https://github.com/reza675/TixCycle)
- **Issues:** [https://github.com/reza675/TixCycle/issues](https://github.com/reza675/TixCycle/issues)

---

## 🙏 Acknowledgments

- Flutter Team untuk framework yang luar biasa
- Firebase & Supabase untuk backend services
- GetX untuk state management yang powerful
- Semua open source contributors

---

<div align="center">
  <p>Made with ❤️ by TixCycle Team</p>
  <p>🎫 Happy Ticketing!  ♻️</p>
</div>
