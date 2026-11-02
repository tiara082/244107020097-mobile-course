# Laporan Praktikum Pemrograman Mobile - Minggu 11

### Data Mahasiswa
- **Nama:** Tiara Febrianie
- **NIM:** 244107020097
- **Kelas:** TI-3I / Presensi 26
- **Program Studi:** D-IV Teknik Informatika
- **Jurusan:** Jurusan Teknologi Informasi
- **Institusi:** Politeknik Negeri Malang (Polinema)


---

## 7. Refleksi Praktikum (Lab Reflection)

### 1. Optimasi mana yang memiliki dampak paling besar dan mengapa?
> Dari hasil profiling yang saya amati, optimasi yang dampaknya paling signifikan adalah **pembatasan memori decode gambar menggunakan `memCacheWidth` dan `memCacheHeight` pada `CachedNetworkImage`**. Sebelum optimasi ini dipasang, setiap kali scroll daftar pengumuman, animasi terasa patah-patah (*stutter*) parah dan DevTools mencatat 14 frame merah (jank) dengan waktu Raster Thread GPU mencapai 21.6 ms. Hal ini terjadi karena gambar yang diunduh dari internet memiliki resolusi asli kamera (sekitar 3000x2000 piksel), padahal kontainer di layar HP cuma berukuran 160 piksel. Begitu decode dibatasi ke ukuran fisik mobile (`memCacheWidth: 480`), beban GPU langsung terpangkas drastis menjadi 4.2 ms dan frame rate seketika stabil di 60 FPS mulus.

### 2. Bagaimana cara kamu memverifikasi bahwa optimasi benar-benar berdampak (bukan sugesti/placebo)?
> Saya memverifikasinya secara objektif menggunakan **Flutter DevTools pada mode `--profile`**, bukan mode `--debug` (karena mode debug memiliki overhead JIT yang membuat performa lambat palsu). Saya membandingkan metrik kuantitatif di tab Performance sebelum dan sesudah optimasi dijalankan pada skenario interaksi yang persis sama (fast scroll 30 item dan 5x navigasi bolak-balik). Dari grafik terlihat jelas bahwa rata-rata frame time turun dari 34.8 ms ke 8.4 ms, jank frames turun dari 14 frame menjadi 0 frame, dan pada Heap Snapshot tab Memory, ukuran memori RAM stabil di angka 24.6 MB tanpa ada lonjakan objek `ScrollController` yang tertinggal.

### 3. Kompromi (*trade-offs*) apa yang kamu hadapi (misalnya kompleksitas kode vs performa)?
> Kompromi utama ada pada **kompleksitas struktur kode yang bertambah**. Sebelumnya, seluruh tampilan feed ditulis menumpuk di dalam satu method `build()` yang sederhana dan cepat dibaca. Namun untuk menghindari *excessive rebuilds*, saya harus memecah widget menjadi kelas-kelas kecil terpisah, menambahkan `RepaintBoundary`, serta menulis selektor Riverpod granular menggunakan `.select()`. Selain itu, gambar yang di-downscale untuk cache memori memang tidak bisa diperbesar (zoom) dengan ketajaman penuh tanpa mengunduh ulang gambar asli beresolusi tinggi, namun untuk kebutuhan thumbnail feed daftar artikel di smartphone, kompromi kualitas ini adalah pilihan terbaik demi kenyamanan pengguna.

### 4. Kapan optimasi dini (*premature optimization*) sebaiknya dihindari?
> Optimasi dini sebaiknya dihindari **saat kita masih berada di tahap eksplorasi awal pembuatan fitur atau ketika rancangan antarmuka dan proses bisnis aplikasi masih sering berubah-ubah**. Jika belum apa-apa kita sudah memusingkan algoritma caching yang rumit atau memasang `RepaintBoundary` di setiap elemen widget tanpa alasan yang jelas, kode akan menjadi kaku (*over-engineered*) dan sulit di-refactor ketika ada perubahan kebutuhan. Pendekatan yang benar adalah membangun kode yang rapi dan modular terlebih dahulu (*make it work, make it clean*), lalu lakukan profiling menggunakan DevTools. Jika terbukti ada bottleneck atau frame rate drop di bawah 60 FPS, barulah kita terapkan optimasi terarah pada titik yang memang bermasalah tersebut (*measure first, optimize later*).

