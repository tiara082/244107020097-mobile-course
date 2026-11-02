# Laporan Praktikum Pemrograman Mobile - Minggu 10

### Data Mahasiswa
- **Nama:** Tiara Febrianie
- **NIM:** 244107020097
- **Kelas:** TI-3I / Presensi 26
- **Program Studi:** D-IV Teknik Informatika
- **Jurusan:** Jurusan Teknologi Informasi
- **Institusi:** Politeknik Negeri Malang (Polinema)


---

## 7. Refleksi Praktikum (Lab Reflection)

### 1. Fitur AI apa yang kamu integrasikan dan apa alasannya?
> Saya mengintegrasikan fitur **Campus AI Assistant** untuk kebutuhan tanya-jawab akademik mahasiswa JTI Polinema. Alasannya, selama ini mahasiswa baru atau mahasiswa semester tengah sering kebingungan mencari info mendasar seperti jadwal ruang lab mobile, batas pengumpulan modul praktikum, atau alur pengurusan KRS saat sistem error. Dengan membuat asisten berbasis Gemini API di smartphone, mahasiswa bisa langsung mengetik pertanyaan dalam bahasa sehari-hari tanpa harus membuka banyak portal web atau mencari-cari pengumuman di grup chat yang sering tertimbun.

### 2. Bagaimana cara kamu melindungi privasi pengguna saat memanggil API AI?
> Sebelum request apapun dikirim ke endpoint Gemini API di cloud, teks dari pengguna wajib melewati proses *sanitasi lokal* di perangkat (`PrivacySanitizer`). Saya memanfaatkan regular expression (Regex) untuk mendeteksi nomor NIK kependudukan, NIM mahasiswa Polinema (10-12 digit), nomor telepon seluler (+62/08...), serta alamat email. Jika pola-pola ini ditemukan, sistem langsung menggantinya dengan label anonim seperti `[NIM_MAHASISWA]` atau `[PHONE_REDACTED]`. Dengan cara ini, data identitas asli mahasiswa tidak pernah tersimpan di log server LLM eksternal. Selain itu, API key juga tidak saya simpan secara hardcoded di kode sumber, melainkan disimpan terenkripsi di `flutter_secure_storage`.

### 3. Fallback apa yang kamu sediakan jika layanan AI mengalami error atau batas kuota habis?
> Saya menerapkan mekanisme *Graceful Degradation* menggunakan rule-based matching lokal. Jika koneksi internet pengguna terputus (`SocketException`), terjadi timeout, atau kuota gratis Gemini terkena limit rate (HTTP 429 Too Many Requests), aplikasi tidak akan crash atau menampilkan error teknis mentah ke layar. Sebagai gantinya, `ChatNotifier` akan mengecek kata kunci umum dari pertanyaan user (misalnya kata "jadwal", "krs", "dpa", "ruang") lalu menyajikan jawaban informasi statis yang tersimpan lokal di aplikasi. Pada chat bubble tersebut juga sengaja saya pasang badge khusus berwarna kuning `Fallback Mode (Offline)` agar pengguna mengetahui bahwa informasi tersebut adalah respon darurat lokal, bukan jawaban dinamis dari AI cloud.

### 4. Satu hal penting yang kamu pelajari mengenai UX fitur AI di perangkat mobile?
> Hal terpenting yang saya pelajari adalah **ekspektasi latensi pengguna di mobile itu sangat sensitif**. Berbeda dengan web yang penggunanya terbiasa menunggu page loading, pengguna aplikasi HP akan langsung mengira aplikasi rusak atau freeze jika setelah menekan tombol kirim tidak ada respon visual dalam 1-2 detik. Oleh karena itu, UX fitur AI di mobile wajib memiliki:
> 1. Indikator loading visual yang jelas (animasi titik berdenyut atau progress bar kecil di atas chat input).
> 2. Tombol input yang dinonaktifkan sementara selama request berlangsung agar user tidak menekan kirim berkali-kali (*spam requests*).
> 3. Prompt chips (saran pertanyaan instan) yang sangat membantu di mobile karena mengetik panjang di keyboard virtual smartphone itu sering kali melelahkan bagi pengguna.

