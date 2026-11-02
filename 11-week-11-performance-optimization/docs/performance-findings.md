# Laporan Identifikasi Masalah Performa (Performance Findings)
## Praktikum Pemrograman Mobile - Minggu 11 (Performance Optimization)

---

### Data Mahasiswa
- **Nama:** Tiara Febrianie
- **NIM:** 244107020097
- **Kelas:** TI-3I
- **Prodi / Jurusan:** D-IV Teknik Informatika / Jurusan Teknologi Informasi - Politeknik Negeri Malang

---

## 1. Ringkasan Observasi Awal (Baseline Profiling)
Pengujian performa awal dilakukan menggunakan **Flutter DevTools** pada mode profil (`flutter run --profile`) terhadap modul feed pengumuman kampus. Skenario pengujian mencakup:
1. Membuka halaman utama feed (*initial cold launch*).
2. Melakukan *fast scrolling* melewati 30 daftar pengumuman.
3. Melakukan interaksi penambahan suka (*like toggle*) pada salah satu artikel.
4. Navigasi bolak-balik antara halaman feed dan halaman detail berulang kali (5x berturut-turut).

### Hasil Metrik Baseline (Sebelum Optimasi):
- **Frame Rate:** ~28.4 FPS (Sering mengalami *frame drops* / *jank*).
- **Rata-rata Frame Time:** 34.8 ms (Melebihi target anggaran 16.67 ms untuk 60 FPS).
- **Jank Frames:** 14 frame berwarna merah (frame time > 32 ms).
- **Raster Thread Latency:** 21.6 ms (Tersumbat oleh proses *image decoding* resolusi mentah).
- **Dart Heap Usage:** 48.2 MB dan terus meningkat setiap navigasi bolak-balik (*leak pattern*).

---

## 2. Rincian Masalah yang Ditemukan (Bottlenecks)

### Masalah 1: *Excessive Widget Rebuilds* pada Seluruh Layar Feed
- **Temuan di DevTools (Performance Tab / Flame Chart):**
  Setiap kali pengguna menekan tombol suka (*like*) pada salah satu item di dalam daftar, seluruh *widget tree* mulai dari `FeedScreen`, `CustomScrollView`, hingga seluruh `FeedItemTile` yang sedang tampil di layar ikut mengalami proses *rebuild*.
- **Penyebab Utama:**
  Penggunaan `ref.watch(feedNotifierProvider)` tanpa filter/selektor granular menyebabkan setiap perubahan kecil pada variabel agregasi `totalLikes` memicu pemanggilan ulang fungsi `build()` pada *parent widget*. Selain itu, komponen-komponen statis seperti header teks dan kartu statistik tidak dideklarasikan sebagai `const`.
- **Dampak Performa:**
  UI Thread CPU mengalami lonjakan beban hingga 13.2 ms per frame hanya untuk mengulang pembuatan objek widget yang sebenarnya tidak mengalami perubahan visual.

### Masalah 2: *Image Decoding Bottleneck* pada Raster Thread (GPU)
- **Temuan di DevTools (Raster Thread Track):**
  Pada saat pengguna melakukan *fast scrolling*, grafik performa menampilkan balok merah panjang bertuliskan `Skia::Codec::decode` dan `Rasterizer::DoDraw`.
- **Penyebab Utama:**
  Gambar thumbnail pengumuman diambil dari URL internet dengan resolusi asli kamera (rata-rata 3000x2000 piksel atau ~3 MB per foto), namun dirender ke dalam kontainer berukuran fisik hanya 160 piksel di layar. Karena tidak ada pembatasan memori decode (`memCacheWidth` & `memCacheHeight`), GPU terpaksa mengalokasikan memori bitmap mentah sebesar puluhan megabyte per frame saat scroll.
- **Dampak Performa:**
  Raster Thread memakan waktu hingga 21.6 ms per frame (jauh melampaui batas 16.67 ms), menimbulkan efek animasi patah-patah (*stutter*) saat daftar digulir.

### Masalah 3: Permintaan Jaringan Berulang Tanpa Mekanisme Cache (*No Caching*)
- **Temuan di DevTools (Network Tab):**
  Setiap kali pengguna berpindah tab atau memuat ulang halaman, aplikasi selalu melakukan pemanggilan HTTP GET baru ke backend API untuk mengambil data halaman pertama, meskipun isi pengumuman tidak mengalami pembaruan sama sekali.
- **Penyebab Utama:**
  Lapisan *Repository* belum menerapkan strategi *Stale-While-Revalidate* (SWR) atau *in-memory caching*. Data yang telah di-fetch langsung dibuang begitu widget tidak lagi aktif.
- **Dampak Performa:**
  Pengguna mengalami *blank loading spinner* selama 300-800 ms setiap kali membuka aplikasi, membuang kuota data seluler, dan membebani server backend secara tidak perlu.

### Masalah 4: Akumulasi Objek Memori (*Memory Leak*) dari Controller yang Tidak di-Dispose
- **Temuan di DevTools (Memory Tab / Heap Snapshot):**
  Setelah melakukan skenario navigasi bolak-balik sebanyak 5 kali, snapshot memori menunjukkan bahwa instance `ScrollController`, `ScrollPositionWithSingleContext`, dan listener closure tidak pernah dihancurkan (*not collected by GC*), sehingga ukuran Heap terus bertambah dari 28 MB menjadi 48.2 MB.
- **Penyebab Utama:**
  `FeedScreen` lupa memanggil `_scrollController.dispose()` dan `_scrollController.removeListener()` pada method `dispose()`.
- **Dampak Performa:**
  Jika aplikasi digunakan dalam jangka waktu lama, akumulasi listener dan posisi scroll yang menggantung akan memicu *Garbage Collection thrashing* dan berisiko ditutup paksa oleh sistem operasi (*Out Of Memory / OOM kill*).

---

## 3. Rencana Tindakan Optimasi Terpilih
Berdasarkan temuan di atas, tindakan optimasi yang diterapkan meliputi:
1. **Pemisahan Widget & `const` Constructors:** Mengisolasi tile pengumuman menjadi widget mandiri dengan konstruktor `const`.
2. **Isolasi Paint dengan `RepaintBoundary`:** Membungkus `MetricsCounterHeader` agar aktivitas repaint animasi counter tidak merembet ke area list pengumuman.
3. **Riverpod Granular `.select()`:** Memecah konsumsi provider menjadi selektor spesifik (`feedTotalLikesProvider`, `feedItemsCountProvider`) sehingga hanya bagian angka yang rebuild.
4. **Pembatasan Dimensi Decode Gambar (`memCacheWidth` & `memCacheHeight`):** Menggunakan `CachedNetworkImage` dengan batas decode memori 480x320 px.
5. **Implementasi Repository Cache (*Stale-While-Revalidate*):** Mengembalikan data cache secara instan saat re-entry dan hanya melakukan network request ketika dipaksa atau cache kosong.
6. **Pembersihan Listener & Controller:** Menerapkan lifecycle `dispose()` yang ketat pada `_scrollController`.
