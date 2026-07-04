<div align="center">

# 🗑️ Bank Sampah Digital
### Aplikasi Mobile Bank Sampah Berbasis Flutter & Firebase

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

> Aplikasi bank sampah digital yang memudahkan masyarakat dalam mengelola sampah, mendapatkan saldo & poin, serta berinteraksi langsung dengan admin melalui fitur chat real-time.

</div>

---

## 📱 Tentang Aplikasi

**Bank Sampah Digital** adalah aplikasi mobile yang dikembangkan sebagai Final Project mata kuliah **Pemrograman Mobile** — Program Studi Sistem Informasi, Universitas AMIKOM Purwokerto.

Aplikasi ini hadir sebagai solusi digital untuk pengelolaan bank sampah konvensional, dengan menghadirkan fitur penjemputan sampah berbasis lokasi GPS, sistem poin & saldo real-time, serta komunikasi langsung antara user dan admin.

---

## ✨ Fitur Utama

### 👤 Sisi User
| Fitur | Deskripsi |
|-------|-----------|
| 🔐 **Autentikasi** | Register & Login menggunakan Firebase Authentication |
| 🏠 **Home Dashboard** | Tampilan saldo, poin terkumpul, dan menu utama |
| 🗑️ **Setor Sampah** | Pilih jenis sampah (Organik/Non-Organik), input berat, dan tentukan lokasi penjemputan via peta OpenStreetMap |
| 📋 **Riwayat Transaksi** | Lihat seluruh riwayat setoran beserta status real-time |
| 👤 **Profil & Edit Data** | Kelola nama, nomor HP, dan alamat lengkap |
| 💬 **Chat Admin** | Komunikasi langsung dengan admin secara real-time |
| 🏆 **Leaderboard** | Ranking user berdasarkan poin yang terkumpul |

### ⚙️ Sisi Admin
| Fitur | Deskripsi |
|-------|-----------|
| 📊 **Dashboard Admin** | Panel kontrol pengelolaan aplikasi |
| ♻️ **Kelola Jenis Sampah** | Tambah, edit, dan hapus jenis sampah beserta harga |
| ✅ **Kelola Transaksi** | Setujui, tolak, atau update status penjemputan sampah |
| 📍 **Akses Lokasi User** | Lihat titik koordinat penjemputan dan buka di Maps |
| 💬 **Balas Pesan User** | Kelola dan balas semua pesan masuk dari user |

---

## 🔄 Alur Penggunaan

```
User Register/Login
        ↓
Setor Sampah (pilih kategori → input berat → pin lokasi di peta)
        ↓
Status: PENDING (menunggu konfirmasi admin)
        ↓
Admin buka lokasi user di Maps → berangkat jemput sampah
        ↓
Status: DIJEMPUT
        ↓
Admin konfirmasi → Status: DISETUJUI
        ↓
Saldo & Poin user otomatis bertambah ✅
```

---

## 🛠️ Tech Stack

| Teknologi | Kegunaan |
|-----------|----------|
| **Flutter** | Framework UI cross-platform |
| **Dart** | Bahasa pemrograman |
| **Firebase Auth** | Autentikasi user |
| **Cloud Firestore** | Database real-time |
| **Provider** | State management |
| **flutter_map** | Peta OpenStreetMap |
| **geolocator** | Akses GPS perangkat |
| **url_launcher** | Buka lokasi di Maps eksternal |
| **intl** | Format tanggal & angka |

---

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK `>=3.0.0`
- Android Studio / VS Code
- Akun Firebase

### Langkah Instalasi

**1. Clone repository**
```bash
git clone https://github.com/USERNAME/bank-sampah-app.git
cd bank-sampah-app
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Setup Firebase**
- Buat project di [Firebase Console](https://console.firebase.google.com)
- Aktifkan **Authentication** (Email/Password)
- Aktifkan **Cloud Firestore** (test mode)
- Download `google-services.json` dan taruh di `android/app/`

**4. Jalankan aplikasi**
```bash
flutter run
```

### Build APK
```bash
flutter build apk --release
```
File APK tersedia di `build/app/outputs/flutter-apk/app-release.apk`

---

## 📂 Struktur Project

```
lib/
├── models/
│   ├── user_model.dart
│   ├── sampah_model.dart
│   └── transaksi_model.dart
├── services/
│   ├── auth_service.dart
│   ├── sampah_service.dart
│   ├── transaksi_service.dart
│   └── chat_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── user/
│   │   ├── home_screen.dart
│   │   ├── setor_sampah_screen.dart
│   │   ├── riwayat_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── chat_screen.dart
│   │   └── leaderboard_screen.dart
│   └── admin/
│       ├── admin_dashboard_screen.dart
│       ├── kelola_sampah_screen.dart
│       ├── kelola_transaksi_screen.dart
│       └── admin_chat_screen.dart
├── widgets/
│   └── location_picker.dart
├── firebase_options.dart
└── main.dart
```

---

## 👥 Tim Pengembang

| Nama | NIM | Prodi |
|------|-----|-------|
| **Azka** | - | Sistem Informasi |

**Universitas AMIKOM Purwokerto**
**Mata Kuliah:** Pemrograman Mobile
**Semester:** 4

---

## 📄 Lisensi

Project ini dibuat untuk keperluan akademik — Final Project Pemrograman Mobile.

---

<div align="center">

**Dibuat dengan ❤️ menggunakan Flutter & Firebase**

⭐ Jangan lupa kasih bintang kalau project ini membantu!

</div>
