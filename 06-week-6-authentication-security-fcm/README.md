# Week 6: Authentication, Security & Firebase Cloud Messaging (FCM)

## Student Details
* **Name:** Tiara Febrianie
* **Student ID (NIM):** 244107020097
* **Class:** TI-3I
* **Department:** Information Technology - State Polytechnic of Malang (Polinema)


---

## Lab Reflections

### 1. Mengapa refresh token dilarang keras disimpan di SharedPreferences? Apa risikonya jika bocor?

Refresh token adalah kredensial berumur panjang (biasanya berlaku selama berminggu-minggu atau berbulan-bulan) yang berfungsi sebagai kunci utama untuk mencetak access token baru setiap kali masa berlaku access token habis. 

`SharedPreferences` di Android dan `NSUserDefaults` di iOS bekerja dengan menyimpan data dalam format file XML/plist biasa tanpa adanya mekanisme enkripsi bawaan di filesystem perangkat. Pada perangkat yang telah di-*root* atau di-*jailbreak*, atau melalui fitur backup data (`adb backup`), file teks biasa ini dapat diekstraksi dan dibaca dengan sangat mudah oleh pihak ketiga atau aplikasi berbahaya yang mengeksploitasi izin penyimpanan.

Jika sebuah refresh token bocor ke tangan penyerang:
* Penyerang dapat terus-menerus meminta access token baru ke server autentikasi tanpa memerlukan interaksi atau persetujuan dari pengguna asli.
* Penyerang dapat menyamar (*impersonate*) sebagai mahasiswa/pengguna tersebut, mengakses riwayat nilai akademik, memodifikasi data pribadi, hingga melakukan aksi administratif tanpa pernah mengetahui password pengguna.
* Kebocoran ini berpotensi bertahan lama hingga token tersebut dicabut (*revoked*) secara manual di sisi server.

Oleh karena itu, refresh token wajib disimpan secara eksklusif di dalam penyimpanan aman tingkat perangkat keras (*hardware-backed secure storage*) seperti `flutter_secure_storage`, yang memanfaatkan Android KeyStore (dengan enkripsi AES-256) dan iOS Keychain Services.

### 2. Apa yang rusak jika `onTokenRefresh` diabaikan selama satu semester penuh?

Token registrasi FCM (*device registration token*) bukanlah pengenal statis yang permanen seumur hidup perangkat. Firebase secara rutin memperbarui atau membatalkan token perangkat dalam berbagai skenario, seperti:
1. Pengguna melakukan instalasi ulang aplikasi (*reinstall*) atau memulihkan data ke perangkat baru.
2. Pengguna membersihkan data aplikasi (*Clear Storage / App Data*) melalui pengaturan ponsel.
3. Firebase merotasi kredensial keamanan aplikasi secara periodik di infrastruktur Google.

Jika aplikasi hanya memanggil `FirebaseMessaging.instance.getToken()` satu kali saat login awal dan sama sekali mengabaikan event stream `onTokenRefresh`:
* Basis data server kampus akan terus menyimpan token lama yang sudah mati (*stale device token*).
* Ketika sistem kampus mengirimkan pengumuman penting (seperti perubahan mendadak jadwal ujian akhir, perpindahan ruang kuliah, atau pengumuman beasiswa), server Firebase akan menolak pengiriman tersebut dengan status kesalahan `UNREGISTERED` atau `NOT_FOUND`.
* Akibatnya, mahasiswa tidak akan pernah menerima satupun notifikasi darurat selama sisa semester berjalan, meskipun aplikasi terpasang di ponsel mereka dan status mahasiswa tersebut aktif. Mengirimkan token baru ke endpoint `POST /devices` melalui `onTokenRefresh` adalah keharusan mutlak agar siklus komunikasi server-ke-perangkat tetap tersinkronisasi.

### 3. Kapan Anda menggunakan topic vs device token? Berikan satu contoh pesan kampus untuk masing-masing kasus.

* **Topic Messaging (`subscribeToTopic`):**
  * Digunakan untuk pola komunikasi satu-ke-banyak (*1-to-Many / Broadcast / Multicast*), di mana pesan ditujukan secara serentak kepada sekelompok besar pengguna yang memiliki ketertarikan atau status yang sama, tanpa mengharuskan server melacak ribuan token perangkat satu per satu.
  * **Contoh Kasus Kampus:** Pengumuman operasional publik ke seluruh civitas akademika melalui topik `pengumuman-kampus`, misalnya:  
    *`"Pemberitahuan: Layanan perpustakaan dan jaringan WiFi kampus ditutup sementara pada hari Sabtu untuk pemeliharaan rutin infrastruktur server."`*
* **Device Token (Direct Unicast Messaging):**
  * Digunakan untuk komunikasi privat satu-ke-satu (*1-to-1*) yang bersifat personal, rahasia, atau memerlukan tingkat keamanan tinggi, di mana pesan hanya boleh sampai ke perangkat spesifik milik pengguna tertentu.
  * **Contoh Kasus Kampus:** Notifikasi akademik individual mengenai status mahasiswa, misalnya:  
    *`"Halo Tiara Febrianie (NIM: 244107020097), Pengajuan Kartu Rencana Studi (KRS) Semester Ganjil Anda telah disetujui oleh Dosen Pembimbing Akademik."`*

### 4. Bagian draf AI mana yang Anda tolak atau perbaiki, dan apa alasannya?

Ketika melakukan audit terhadap draf awal kode `PushService` dan integrasi autentikasi yang dihasilkan oleh AI, saya menemukan beberapa kesalahan arsitektural krusial dan melakukan perbaikan mandiri:

Pertama, AI menempatkan background handler `firebaseMessagingBackgroundHandler` sebagai method di dalam kelas `PushService`. Dalam arsitektur Flutter, saat aplikasi berada di background atau dimatikan, pesan masuk ditangani di isolate Dart baru yang terisolasi dari pohon widget utama. Method kelas atau *instance closure* tidak dapat diakses dan akan menyebabkan crash senyap. Saya memperbaikinya dengan mengeluarkan handler tersebut menjadi fungsi top-level independen yang ditandai dengan anotasi `@pragma('vm:entry-point')`.

Kedua, AI berasumsi bahwa notifikasi FCM akan otomatis menampilkan banner di layar saat aplikasi sedang dibuka di foreground. Pada kenyataannya, sistem operasi Android dan iOS membisukan banner foreground secara default. Saya memperbaiki ini dengan mengintegrasikan `flutter_local_notifications`, mendengarkan stream `FirebaseMessaging.onMessage`, dan memunculkan heads-up notification secara manual menggunakan channel Android berprioritas tinggi.

Ketiga, pada implementasi `onTokenRefresh`, AI hanya menuliskan `print('Token refreshed: $token')`. Ini melanggar standar kepatuhan keamanan karena mencetak token ke log konsol dan menyebabkan token baru tidak pernah tersimpan di server. Saya merefaktornya menjadi panggilan asinkron ke callback backend agar token di server langsung diperbarui.

Keempat, pada Dio interceptor saat menangani HTTP 401, AI tidak menyertakan mekanisme pelindung percobaan ulang (*retry guard*). Jika refresh token telah kedaluwarsa atau server auth tetap merespons 401, aplikasi akan terjebak dalam *infinite recursive loop* pemanggilan refresh yang membebani jaringan dan membekukan aplikasi. Saya menambahkan penanda `extra['retried'] = true` dan pembersihan sesi otomatis (`store.clear()`) jika proses pembaruan token gagal.

