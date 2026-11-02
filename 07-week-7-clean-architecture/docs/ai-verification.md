# AI Verification & Architecture Refactoring Audit — Week 7: Clean Architecture

Dokumentasi audit teknis, evaluasi usulan restrukturisasi AI, pemetaan berkas lama ke arsitektur baru, dan analisis *trade-off* Clean Architecture berbasis fitur (*feature-first*).

---

## 👨‍🎓 Student Details
* **Nama:** Tiara Febrianie
* **NIM:** 244107020097
* **Kelas:** TI-3I
* **Program Studi:** D4 Teknik Informatika, Jurusan Teknologi Informasi
* **Institusi:** Politeknik Negeri Malang (Polinema)

---

## 1. Prompt AI yang Digunakan (AI Prompt Challenge)

```text
My Flutter project: campus_notify (auth + FCM + announcement list).
Current state: lib/{data, providers, pages, messaging} folders,
repositories mixed with implementations, widgets calling Dio directly.
Tasks:
1. Propose a feature-first Clean Architecture structure
   (presentation/domain/data) for the auth + announcements features.
2. For each old file, state its new destination (move/split/delete).
3. Flag what would be over-engineering if applied to simple CRUD,
   and when a use case is truly needed vs repository straight to notifier.
4. Show the Riverpod DI wiring (no extra DI package).
Explain the trade-off of every decision.
```

---

## 2. Pemetaan Berkas Lama ke Arsitektur Baru (*File Migration Table*)

| Berkas Lama (Week 6) | Tindakan | Lokasi Baru (Week 7) | Alasan Arsitektural |
|---|---|---|---|
| `lib/data/auth_repository.dart` | **Split** | • `lib/features/auth/domain/repositories/auth_repository.dart`<br>• `lib/features/auth/data/repositories/auth_repository_impl.dart`<br>• `lib/features/auth/domain/entities/auth_session.dart` | Memisahkan kontrak antarmuka (*interface contract*) murni dari implementasi storage/HTTP. |
| `lib/data/token_store.dart` | **Move** | `lib/features/auth/data/repositories/auth_repository_impl.dart` (internal data source) | Token storage adalah detail teknis infrastruktur penyimpanan lokal, bukan domain inti. |
| `lib/providers/auth_provider.dart` | **Split** | • `lib/features/auth/domain/usecases/login_usecase.dart`<br>• `lib/features/auth/presentation/providers/auth_notifier.dart` | Memisahkan orkestrasi logika login dari *state presentation*. |
| `lib/pages/login_page.dart` | **Move** | `lib/features/auth/presentation/pages/login_page.dart` | Komponen visual UI dikelompokkan per fitur. |
| `lib/pages/home_page.dart` | **Refactor** | `lib/features/announcements/presentation/pages/announcements_page.dart` | Beranda difokuskan sebagai daftar pengumuman kampus berarsitektur bersih. |
| `lib/pages/announcement_page.dart` | **Move** | `lib/features/announcements/presentation/pages/announcement_detail_page.dart` | Halaman detail pengumuman dikelompokkan ke presentation feature announcements. |
| `lib/messaging/push_service.dart` | **Split** | • Helper formatting ke `lib/core/format.dart`<br>• Handler rute dipertahankan di level app routes | Fungsi utilitas murni diekstrak agar dapat diuji tanpa dependensi plugin native. |
| `lib/routes.dart` | **Keep** | `lib/routes.dart` | Konfigurasi rute dan deep-link global tingkat aplikasi. |

---

## 3. Matriks Keputusan: Usulan AI vs Keputusan Mahasiswa

| Aspek Arsitektural | Usulan Awal AI | Keputusan & Refaktor Mahasiswa | Rasional & Justifikasi Teknis |
|---|---|---|---|
| **Lokasi Repository Interface** | Menyarankan meletakkan kontrak dan implementasi dalam satu folder `data/` | **Ditolak & Dipisahkan**: Kontrak abstrak diletakkan di `domain/repositories/`, sedangkan implementasi di `data/repositories/` | Menerapkan **Dependency Inversion Principle (DIP)**. Domain layer harus independen dan tidak boleh bergantung pada layer luar (*inward dependency*). |
| **Kebutuhan Use Case** | AI membuat use case untuk seluruh operasi (misal: `GetAnnouncementDetail`, `LogoutUseCase`, `CheckSessionUseCase`) | **Disederhanakan**: Hanya operasi yang membawa logika bisnis (validasi, autentikasi sesi, filter) yang dibuatkan class use case terpisah | Mencegah *over-engineering boilerplate*. Operasi pembacaan pasif satu baris dapat langsung dipanggil dari notifier jika tidak ada mutasi atau aturan bisnis tambahan. |
| **Pemisahan Entity & Model** | Menyarankan entity langsung memiliki `fromJson` dan `toJson` | **Ditolak & Dipisahkan**: Entity di domain dibuat murni (Plain Dart Object tanpa impor eksternal). Serialisasi hanya ada pada `AnnouncementModel` di data layer | Domain entity harus steril dari urusan format serialisasi JSON/SQL yang rentan berubah sewaktu-waktu. |
| **Dependency Injection** | Mengusulkan penambahan package DI baru (`get_it` + `injectable`) | **Ditolak**: Memanfaatkan **Flutter Riverpod** bawaan yang sudah ada | Riverpod sudah menyediakan *compile-time dependency injection* yang deklaratif dan sangat mudah di-override pada unit testing tanpa menambah beban dependency (*zero overhead*). |

---

## 4. Pembuktian Sterilitas Layer (*Sterility Grep Verification*)

Aturan Clean Architecture mengharuskan:
1. **Presentation Layer:** Bebas dari pemanggilan langsung driver data, client HTTP, atau database (`Dio`, `openDatabase`, `FlutterSecureStorage`, `jsonDecode`).
2. **Domain Layer:** Bebas dari framework UI atau plugin pihak ketiga (`flutter`, `dio`, `sqflite`, `firebase`).

### Hasil Eksekusi Grep:
```bash
# 1. Cek Presentation Layer (harus 0 hit)
Get-ChildItem -Path 'lib\features\*\presentation' -Recurse -Filter '*.dart' | Select-String -Pattern 'Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode'
# Hasil: 0 hits (STERIL)

# 2. Cek Domain Layer & Core (harus 0 hit)
Get-ChildItem -Path 'lib\features\*\domain', 'lib\core' -Recurse -Filter '*.dart' | Select-String -Pattern "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase"
# Hasil: 0 hits (STERIL)
```
Semua pengecekan lulus 100% tanpa pelanggaran dependensi silang.
