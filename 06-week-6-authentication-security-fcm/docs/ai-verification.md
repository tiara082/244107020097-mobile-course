# AI Verification & Architecture Audit — Week 6: Authentication, Security & FCM

Dokumentasi proses audit teknis, prompt AI, temuan validasi manual, dan keputusan arsitektural pada modul autentikasi dan Firebase Cloud Messaging (FCM).

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
Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications, flutter_secure_storage, go_router, Riverpod.
Generate a PushService with:
- requestPermission + getToken + onTokenRefresh (send to POST /devices)
- onMessage (show a local notification manually)
- onMessageOpenedApp + getInitialMessage (navigate to data.route)
- subscribe/unsubscribe topic campus-announcement
- top-level background handler with @pragma('vm:entry-point')
Mark which parts DIFFER for Android 13+ vs iOS,
and which parts must never touch BuildContext.
```

---

## 2. Pemeriksaan Manual & Matriks Evaluasi (AI Verification Checklist)

| Aspek Pemeriksaan | Standar Kelayakan | Draf Awal AI | Tindakan & Keputusan Mahasiswa | Status |
|---|---|---|---|---|
| **Top-Level Background Handler** | Wajib berupa fungsi top-level terpisah dengan anotasi `@pragma('vm:entry-point')` | Draf meletakkannya sebagai method kelas di dalam `class PushService` | **Ditolak & Diperbaiki**: Method kelas tidak dapat diakses pada isolate baru saat background/terminated. Dipindahkan ke top-level function di luar kelas. | **LULUS** |
| **Siklus Hidup Token (`onTokenRefresh`)** | Token baru wajib dikirim ke backend (`POST /devices`) | Draf hanya melakukan `print('Token: $token')` | **Ditolak & Diperbaiki**: `print()` melanggar audit keamanan OWASP dan membuat token di database server menjadi kedaluwarsa (stale). Diintegrasikan ke callback asinkron backend. | **LULUS** |
| **Banner Notifikasi Foreground** | Wajib menampilkan banner manual via `flutter_local_notifications` | Draf berasumsi FCM otomatis memunculkan heads-up banner | **Ditolak & Diperbaiki**: Android & iOS secara default membisukan heads-up notifikasi saat app berada di foreground. Dibuatkan channel berprioritas tinggi dan `_local.show()` manual. | **LULUS** |
| **Navigasi 3 State (Deep Linking)** | Menangani klik dari Foreground, Background, dan Terminated | Menggunakan `Navigator.push` dengan `BuildContext` statis | **Ditolak & Diperbaiki**: Mengekstrak parser rute menjadi pure function `routeFromMessage()` yang dihubungkan ke `GoRouter` tanpa ketergantungan `BuildContext` langsung. | **LULUS** |
| **Keamanan Kredensial & Token** | Refresh token wajib di Hardware Keystore/Keychain | Sempat menyarankan `shared_preferences` untuk token session | **Ditolak**: `shared_preferences` menyimpan file XML/plist tanpa enkripsi. Wajib menggunakan `flutter_secure_storage` (`TokenStore`). | **LULUS** |

---

## 3. Analisis Perbedaan Platform (Android 13+ vs iOS)

1. **Izin Notifikasi Runtime:**
   * **Android 13+ (API 33+):** Membutuhkan izin runtime eksplisit `android.permission.POST_NOTIFICATIONS`. Jika pengguna menolak dialog sistem, banner tidak akan pernah muncul meskipun token FCM berhasil digenerate.
   * **iOS:** Memerlukan izin APNs eksplisit (`alert: true, badge: true, sound: true`). Selain itu, device token APNs harus dikonversi oleh SDK Firebase menjadi token registrasi FCM.
2. **Channel Notifikasi:**
   * **Android:** Membutuhkan `AndroidNotificationChannel` dengan `importance: Importance.high` agar banner notifikasi dapat melayang di layar (heads-up display).
   * **iOS:** Menggunakan pengaturan `DarwinNotificationDetails` dan konfigurasi presentasi foreground bawaan sistem.

---

## 4. Batasan Kritis: Area yang Tidak Boleh Menyentuh `BuildContext`

1. **`firebaseMessagingBackgroundHandler`:**
   * Fungsi ini dieksekusi oleh mesin Dart pada isolate terpisah saat aplikasi berada di background atau terminated. Pada isolate ini, pohon widget Flutter tidak aktif dan objek `BuildContext` sama sekali tidak eksis. Mengakses UI atau konteks di sini akan memicu fatal crash.
2. **`onTokenRefresh` listener:**
   * Dijalankan secara asinkron dari event native kapan pun token diperbarui oleh Google Play Services. Callback ini tidak boleh bergantung pada konteks layar tertentu, melainkan memanggil modul repository atau service network secara mandiri.
3. **Pending Deep Link Navigation:**
   * Saat aplikasi dibuka dari kondisi *Terminated* via notifikasi, `getInitialMessage()` dieksekusi sebelum frame UI pertama dirender. Navigasi harus disimpan ke variabel sementara (`pendingDeepLink`) atau diteruskan ke konfigurasi router awal (`initialLocation`) tanpa memaksakan panggilan `context.go()` sebelum MaterialApp terpasang.
