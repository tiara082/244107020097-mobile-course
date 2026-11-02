# AI Integration Log & Prompt Engineering Documentation

Dokumentasi implementasi fitur AI Assistant pada aplikasi mobile kampus JTI Polinema (*Week 10 - Mobile Application Development*).

---

## 1. Identitas Mahasiswa & Project
- **Nama:** Tiara Febrianie
- **NIM:** 244107020097
- **Kelas:** TI-3I
- **Prodi / Jurusan:** D-IV Teknik Informatika / Jurusan Teknologi Informasi - Politeknik Negeri Malang
- **Fitur AI:** *Campus AI Assistant* (Q&A Akademik Terintegrasi Gemini API & Fallback Offline)

---

## 2. System Prompt Engineering

### Konfigurasi Model
- **Provider & Model:** Google Gemini API (`gemini-1.5-flash`)
- **API Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`
- **Temperature:** `0.3` (Diatur rendah agar jawaban faktual, konsisten, dan meminimalkan halusinasi informasi akademik).
- **Max Output Tokens:** `800` (Menghemat kuota token dan menjaga ringkasan tetap padat untuk layar ponsel).

### Teks System Instruction
```text
Kamu adalah Campus AI Assistant untuk mahasiswa Jurusan Teknologi Informasi Politeknik Negeri Malang (JTI Polinema).
Tugas utamanya adalah menjawab pertanyaan seputar perkuliahan, jadwal praktikum mobile, presensi, tugas, dan kegiatan akademik secara ramah, ringkas, jelas, dan akurat dalam Bahasa Indonesia.
Batasi respon maksimal 2-3 paragraf singkat agar mudah dibaca di layar ponsel. Jangan memberikan instruksi palsu atau melanggar etika akademik.
```

### Pertimbangan Desain System Prompt
1. **Persona Kampus Spesifik:** AI langsung diposisikan sebagai asisten JTI Polinema, sehingga tone bicara sopan dan fokus konteks kampus.
2. **Constraint Panjang Karakter:** Layar smartphone terbatas; prompt membatasi respon maksimal 2-3 paragraf agar mahasiswa tidak perlu scrolling terlalu panjang.
3. **Integritas Akademik:** AI secara eksplisit diinstruksikan tidak membocorkan kunci jawaban ujian atau membuatkan tugas secara ilegal.

---

## 3. Privacy & PII Sanitization Log

Sesuai regulasi privasi data dan perlindungan data pribadi mahasiswa (UU PDP / regulasi institusi), aplikasi menerapkan filter lokal (`PrivacySanitizer`) di perangkat pengguna **sebelum** teks dikirimkan ke cloud Gemini API.

### Pola Regex PII & Aturan Sanitasi
| Jenis Data Sensitif | Pola Regex | Hasil Penggantian | Alasan Perlindungan |
| :--- | :--- | :--- | :--- |
| **NIK (16 Digit)** | `\b\d{16}\b` | `[NIK_PROTECTED]` | Mencegah kebocoran identitas kependudukan nasional mahasiswa |
| **NIM Polinema (10-12 Digit)** | `\b\d{10,12}\b` | `[NIM_MAHASISWA]` | Mencegah pelacakan identitas mahasiswa pada server LLM eksternal |
| **Nomor Telepon / WA** | `\b(?:\+?62\|0)8\d{8,11}\b` | `[PHONE_REDACTED]` | Melindungi nomor pribadi dosen/mahasiswa dari scraping & log pihak ketiga |
| **Alamat Email** | `\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b` | `[EMAIL_REDACTED]` | Mencegah eksposur email kampus/pribadi |

### Contoh Hasil Sanitasi Sebelum Request Dikirim
```dart
// Input Asli Pengguna di ChatScreen:
"Nama saya Tiara, NIM 244107020097, NIK 3507112233445566, no HP 081234567890, email tiara@polinema.ac.id. Mau tanya jadwal UTS."

// Output Sanitasi yang Dikirim ke Gemini API:
"Nama saya Tiara, NIM [NIM_MAHASISWA], NIK [NIK_PROTECTED], no HP [PHONE_REDACTED], email [EMAIL_REDACTED]. Mau tanya jadwal UTS."
```

---

## 4. Sample Prompt & AI Response Exchanges

### Exchange 1: Informasi Jadwal Kuliah Mobile
- **User Prompt (Sanitized):**
  > "Kapan jadwal kelas Pemrograman Mobile untuk kelas TI-3I?"
- **Gemini API Response:**
  > "Halo! Perkuliahan Praktikum Pemrograman Mobile untuk kelas TI-3I dijadwalkan setiap hari Rabu pukul 13.00 - 16.40 WIB di Ruang Laboratorium Komputer Gedung Sipil Lantai 2 Polinema.\n\nPastikan sudah melakukan pull repository materi modul mingguan dan memeriksa checklist tugas sebelum kelas dimulai ya!"
- **Analisis:** Jawaban terarah, langsung to the point, dan tidak bertele-tele.

### Exchange 2: Penanganan Offline / Graceful Degradation (Simulasi Network Dropout / Quota 429)
- **User Prompt:**
  > "Bagaimana cara validasi KRS semester ini jika terlambat?"
- **Status API:** Simulasi `SocketException` (Internet mati / API timeout).
- **Fallback Response (Local Rule-based Matching):**
  > "[Mode Offline / Fallback Lokal]\nValidasi KRS: Mahasiswa yang belum tervalidasi dapat menghubungi Dosen Pembina Akademik (DPA) masing-masing atau melapor ke admin jurusan di Gedung Sipil Lt. 1."
- **Analisis:** Aplikasi tidak crash atau menampilkan pesan error teknis mentah; badge `Fallback Mode (Offline)` muncul di UI untuk memberitahu user secara jujur bahwa jawaban berasal dari cache lokal.

---

## 5. Token Usage & Cost Management Strategy

1. **Pemilihan Model Ekonomis (`gemini-1.5-flash`):**
   - Biaya token jauh lebih terjangkau dibandingkan model pro, dengan latensi *time-to-first-token* (TTFT) sangat cepat yang ideal untuk mobile UX.
2. **Max Output Token Cap (`maxOutputTokens: 800`):**
   - Mencegah model menghasilkan teks berulang tak terkontrol yang menghabiskan kuota harian free-tier (15 RPM / 1.500 RPD).
3. **Penyimpanan Kunci API Aman (`flutter_secure_storage`):**
   - Kunci API tidak di-hardcode di kode program (`main.dart` / git repository).
   - Pengguna memasukkan kunci API melalui dialog settings yang disimpan di Android Keystore / iOS Keychain.
4. **Keyword Caching & Rule-based Offline Fallback:**
   - Pertanyaan umum (jadwal, KRS, presensi, dosen DPA) memiliki basis data respon lokal sehingga tetap dapat dijawab tanpa memotong kuota API ketika jaringan offline atau kuota habis (HTTP 429).
