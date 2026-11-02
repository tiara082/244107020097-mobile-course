# Week 7: Feature-First Clean Architecture

## Student Details
* **Name:** Tiara Febrianie
* **Student ID (NIM):** 244107020097
* **Class:** TI-3I
* **Department:** Information Technology - State Polytechnic of Malang (Polinema)


---

## Lab Reflections

### 1. Mengapa interface repository harus berada di domain, bukan di data? Apa yang rusak jika posisinya dibalik?

Dalam Clean Architecture, aturan ketergantungan (*Dependency Rule*) menyatakan bahwa panah dependensi kode hanya boleh mengarah ke dalam, yaitu menuju lapisan inti bisnis (*Domain*). 

Jika kontrak interface diletakkan di dalam folder `domain/repositories/`:
* Lapisan domain mendefinisikan kebutuhan bisnisnya sendiri secara murni, tanpa peduli apakah data nantinya diambil dari REST API Dio, SQLite, Firebase, atau sekadar memori sementara.
* Lapisan `data` berada di luar dan mengimplementasikan kontrak tersebut (*Dependency Inversion Principle*). Lapisan `presentation` cukup memanggil kontrak abstrak domain.

Sebaliknya, jika kontrak interface ditaruh di dalam folder `data/`:
* Lapisan `domain` terpaksa mengimpor folder `data` agar bisa mengenali interface repositori tersebut.
* Akibatnya, hierarki terbalik: aturan bisnis inti menjadi bergantung pada lapisan infrastruktur luar. Jika tim ingin mengganti library database atau menguji use case secara terisolasi, domain ikut terikat (*tight coupling*). Hal ini merusak portabilitas kode dan membuat unit test domain sulit dijalankan tanpa membawa dependensi data luar.

### 2. Kapan sebuah use case benar-benar dibutuhkan, dan kapan pemanggilan repository langsung ke notifier sudah cukup?

Sebuah **Use Case** (atau Interactor) benar-benar dibutuhkan ketika:
1. **Ada Logika Bisnis & Validasi:** Terdapat aturan bisnis spesifik sebelum atau sesudah data diambil, seperti memvalidasi format email, memeriksa saldo minimum, atau mengenkripsi payload.
2. **Orkestrasi Multi-Repository:** Alur kerja membutuhkan penggabungan data dari beberapa sumber sekaligus (misalnya: mengambil profil mahasiswa dari SQLite, mengambil jadwal kuliah dari REST API, lalu menggabungkannya menjadi satu model komposit).
3. **Pemberian Hak Akses & Sesi:** Mengatur transisi alur yang kompleks (misalnya proses login yang harus memanggil API, menyimpan token ke secure storage, dan mereset status cache).

Sebaliknya, pola **Repository langsung ke Notifier/StateProvider** sudah lebih dari cukup untuk operasi baca pasif (*simple 1-line CRUD / pass-through query*). Misalnya hanya memanggil `repository.getAnnouncements()` tanpa transformasi atau aturan bisnis tambahan. Memaksakan pembuatan class use case hanya untuk meneruskan satu baris kode panggilan repositori adalah bentuk *over-engineering* yang tidak memberikan nilai tambah dan hanya menambah boilerplate.

### 3. Apa kerugian over-engineering (membuat use case untuk setiap 1 baris CRUD) bagi tim kecil? Kapan biaya tersebut sepadan?

Bagi tim pengembang berskala kecil (1–4 developer) dengan waktu rilis yang ketat:
* **Beban Pemeliharaan & Boilerplate:** Setiap kali ada fitur kecil, developer harus membuat dan menyinkronkan 4–5 berkas sekaligus (`Entity`, `Model`, `Repository Interface`, `Repository Impl`, `UseCase`, dan `Provider`).
* **Kecepatan Pengembangan Melambat (*Cognitive Overhead*):** Developer harus berpindah-pindah tab berkas hanya untuk menelusuri alur pembacaan data sederhana. Ketika ada perubahan skema field, perubahan harus diulang di banyak tempat.
* **Biaya Refactoring Tinggi:** Jika spesifikasi produk masih sering berubah-ubah di awal (*frequent pivot*), arsitektur yang terlalu kaku memperlambat iterasi.

Biaya tersebut **sepadan (*worth it*)** ketika:
* Aplikasi sudah memasuki tahap produksi dengan puluhan pengembang yang bekerja paralel dalam tim-tim berbeda.
* Fitur memiliki aturan bisnis yang kritis (misalnya modul transaksi keuangan, validasi KRS akademik, atau sistem perbankan), di mana setiap use case wajib diuji unit test secara independen hingga 100% *code coverage* tanpa mempedulikan UI.

### 4. Bagian usulan AI mana yang Anda tolak atau sederhanakan, dan apa alasannya?

Ketika meninjau draf usulan yang diberikan oleh AI untuk refactoring Week 7:
1. **Menolak Pembuatan Use Case untuk Setiap Baris Kode:** AI mengusulkan pembuatan class use case untuk semua fungsi CRUD pasif (seperti `FetchAnnouncementDetailUseCase`, `GetThemeModeUseCase`, dll). Saya menyederhanakannya: hanya alur dengan logika bisnis (seperti `LoginUseCase`, `GetAnnouncements`) yang dipertahankan sebagai use case terpisah, sedangkan operasi pembacaan pasif langsung diakses dari notifier.
2. **Menolak Dependency Injection Menggunakan Paket Tambahan:** AI merekomendasikan penambahan library eksternal seperti `get_it` dan `injectable` lengkap dengan generator `build_runner`. Saya menolak ini karena aplikasi sudah menggunakan Riverpod. Riverpod sudah berfungsi sebagai DI container tingkat kompilasi yang sangat bersih, aman dari null-pointer, dan mudah di-override pada pengujian (`ProviderScope(overrides: [...])`).
3. **Memisahkan Model dari Entity Domain:** Draf awal AI menaruh method `fromJson()` dan `toJson()` langsung di dalam entity domain `Announcement`. Saya memisahkannya secara tegas: entity di `domain` tetap murni tanpa impor library eksternal, sedangkan serialisasi data dipindahkan ke `AnnouncementModel` di dalam `data/models/`.

