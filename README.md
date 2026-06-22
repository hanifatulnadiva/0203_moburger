# 🍔 MoBurger - Aplikasi Manajemen Transaksi dan Pemesanan Burger

MoBurger adalah aplikasi mobile berbasis Flutter untuk pemesanan burger secara online, yang melayani dua peran pengguna dalam satu aplikasi: **Admin** dan **Customer**. Aplikasi ini dibangun menggunakan pola arsitektur **BLoC (Business Logic Component)** dengan **Supabase** sebagai backend (database autentikasi).

---

## 📌 Problem Statement

Proses pemesanan burger secara konvensional (datang langsung ke toko atau memesan via chat/telepon) sering menimbulkan beberapa masalah, di antaranya:

- **Antrian dan waktu tunggu** yang tidak efisien, terutama saat jam ramai.
- **Pencatatan pesanan manual** yang rentan terhadap kesalahan input dan kehilangan data.
- **Minimnya transparansi status pesanan** — pelanggan tidak tahu sejauh mana progres pesanan mereka (diproses, dimasak, siap diambil).
- **Sulitnya rekapitulasi laporan penjualan** bagi admin/pemilik toko karena dilakukan secara manual.
- **Proses pembayaran yang belum terintegrasi**, sehingga verifikasi transaksi memakan waktu lebih lama.

**MoBurger** hadir sebagai solusi dengan menyediakan sistem pemesanan digital yang terintegrasi, mencakup pengelolaan menu, transaksi, pembayaran online, pelacakan status pesanan secara real-time, hingga laporan penjualan otomatis — dalam satu aplikasi yang dapat diakses oleh Admin maupun Customer sesuai perannya masing-masing.

---

## 💡 Proposed Solution

MoBurger adalah solusi aplikasi *mobile-first* yang dikembangkan menggunakan framework **Flutter** dengan pendekatan arsitektur **BLoC (Business Logic Component)** untuk menjamin pemisahan logika bisnis dan tampilan UI yang bersih serta mudah di-*maintain*.

Untuk mengatasi kendala operasional yang ada, MoBurger mengusulkan solusi integratif berikut:

* **Sistem Manajemen Terpusat (Centralized Backend):** Menggunakan **Supabase** sebagai *backend-as-a-service*, MoBurger menyediakan sinkronisasi data antara admin dan pelanggan. Hal ini menghilangkan disparitas informasi mengenai ketersediaan menu dan status pesanan.
* **Otomasi Transaksi & Pelacakan:** Dengan mengintegrasikan **Midtrans**, proses verifikasi pembayaran tidak lagi manual, sehingga mengurangi *human error*. Selain itu, penggunaan **QR Code** sebagai bukti pengambilan pesanan memastikan validasi di sisi *merchant* menjadi lebih cepat dan aman.
* **Efisiensi Alur Kerja (Workflow Automation):** Admin diberikan *dashboard* khusus yang mampu menampilkan performa penjualan secara visual (**fl_chart**). Dengan fitur **Export to Excel**, kebutuhan pelaporan yang sebelumnya memakan waktu berjam-jam kini dapat dilakukan hanya dengan satu klik.
* **User-Centric Experience:** Aplikasi dirancang dengan alur yang intuitif bagi pelanggan, mulai dari kustomisasi pesanan (topping), proses *checkout* yang transparan, hingga status pesanan secara *real-time*, yang secara langsung meningkatkan kepercayaan dan kenyamanan pengguna.
* **Scalability & Performance:** Dengan struktur folder berbasis *Clean Architecture* dan pemanfaatan **flutter_bloc**, aplikasi ini memiliki tingkat *reusability* komponen yang tinggi, memudahkan pengembangan fitur di masa depan.
  
## ✨ Fitur (Features)

### Customer
- Registrasi & login akun
- Melihat daftar menu burger beserta detail dan topping
- Menambahkan item ke keranjang (cart) dengan pilihan quantity & topping
- Checkout dan pembayaran online terintegrasi **Midtrans** (via WebView)
- Pelacakan status pesanan secara **real-time** (timeline pesanan)
- Menampilkan **QR Code** sebagai bukti pengambilan pesanan
- Riwayat pesanan pelanggan
- Halaman profil pengguna

### Admin
- Dashboard admin dengan navigasi terpisah dari customer
- Kelola data menu burger 
- Kelola data topping
- Kelola & pantau riwayat pesanan seluruh pelanggan, dengan filter status dan pagination
- Laporan penjualan dengan visualisasi **grafik (bar chart & pie chart)**
- **Ekspor laporan ke Excel**
- Update status pesanan pelanggan

### Umum
- Autentikasi menggunakan Supabase Auth 
- State management terstruktur menggunakan **flutter_bloc**
- Dukungan mode onboarding untuk pengguna baru
- Light/responsive UI dengan komponen reusable (DRY)

---

## 🗂️ Struktur Folder

Struktur berikut difokuskan pada folder `lib/` (kode sumber utama) dan `assets/`. Folder hasil build (`build/`, `.dart_tool/`, `.gradle/`, dll.) tidak ditampilkan karena bersifat sementara/auto-generated.

```
moburger/

├── lib/

│   ├── bloc/                      # State management (BLoC pattern)

│   │   ├── auth/                  # Login, register, sesi pengguna

│   │   ├── cart/                  # Keranjang belanja

│   │   ├── menu/                  # Data menu burger

│   │   ├── order/                 # Transaksi & status pesanan

│   │   ├── report/                # Data laporan penjualan

│   │   └── topping/               # Data topping tambahan

│   │

│   ├── core/

│   │   ├── contants/              # Konstanta aplikasi (warna, teks, config)

│   │   ├── exceptions/            # Custom exception handler

│   │   ├── network/                # Pengecekan koneksi internet

│   │   ├── service/                # Service pendukung (mis. export Excel)

│   │   └── widget/                 # Widget reusable (button, card, dialog, dll.)

│   │

│   ├── data/

│   │   ├── models/                 # Model data (Menu, Order, Topping, User, Report)

│   │   └── repositories/           # Layer akses data ke Supabase

│   │

│   ├── ui/

│   │   ├── Onboarding/              # Halaman onboarding awal

│   │   ├── auth/                    # Halaman login & register

│   │   ├── camera/                  # Fitur kamera (foto profil/menu)

│   │   ├── dashboard/                # Dashboard admin & customer

│   │   ├── menu/                     # Tampilan & form menu (admin/customer)

│   │   ├── order/

│   │   │   ├── history_order/        # Riwayat pesanan (admin & user)

│   │   │   ├── order_detail/         # Cart, checkout, pembayaran Midtrans

│   │   │   └── pemantauan/           # Pelacakan status pesanan & QR code

│   │   ├── profile/                  # Halaman profil & about

│   │   ├── report/                   # Laporan penjualan (chart & export)

│   │   └── topping/                  # Kelola data topping

│   │

│   └── main.dart                    # Entry point aplikasi

│

├── assets/                          # Gambar, ikon, dan animasi (Lottie)

├── android/ / ios/ / web/ / etc.     # Platform-specific files (auto-generated Flutter)

├── test/                            # Unit/widget test

└── pubspec.yaml                     # Daftar dependencies & konfigurasi project
```

### Teknologi Utama
| Kategori | Teknologi |
|---|---|
| Framework | Flutter |
| State Management | flutter_bloc|
| Backend & Auth | Supabase (supabase_flutter) |
| Pembayaran | Midtrans |
| Penyimpanan Lokal | flutter_secure_storage |
| Visualisasi Data | fl_chart |
| Export Laporan | excel|
| Lainnya | qr_flutter, camera, image_picker|

---

## 📋 Progres Pengerjaan

| Minggu | Progress |
| :--- | :--- |
| **1 (2 juni - 6 juni)** | 1. Inisialisasi project Flutter, setup struktur folder (bloc, core, data, ui).<br>2. Konfigurasi Supabase.<br>3. Implementasi autentikasi (login & register) dan role-based navigation (admin/customer).<br>4. implementasi widegt untuk bottom bar, alert , search, header dan splach screen <br> 5. implementasi dahboard customer |
| **2 (7 juni -13 juni 2026)** | 1. Implementasi modul menu (CRUD menu, topping) untuk admin & tampilan menu untuk customer. <br> 2. Implementasi keranjang belanja (cart) dan alur checkout.<br>2. Integrasi pembayaran online via Midtrans (WebView). |
| **3 (14 juni - 20 juni 2026)** | 1. Implementasi riwayat pesanan admin (filter status & pagination) dan laporan penjualan (chart + export Excel).<br>2. Perbaikan bug (RLS policy, race condition registrasi, status mismatch) <br>3. Implementasi pelacakan status pesanan real-time & QR code pengambilan pesanan. |
|**4 (21 juni-22 juni 2026)**| polishing UI, validasi dan dokumentasi|
---

## 🚀 Cara Menjalankan Project

```bash
flutter pub get
flutter run
```

Pastikan environment Flutter sudah terpasang dan terkoneksi ke device/emulator.
