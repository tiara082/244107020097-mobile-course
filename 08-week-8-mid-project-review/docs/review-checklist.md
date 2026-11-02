# Review Checklist & Collaboration Hygiene — Week 8: Mid-Project Review

Panduan kolaborasi tim, audit riwayat Git, pemodelan cabang GitFlow, dan daftar periksa peer review kode.

---

## 👨‍🎓 Student Details
* **Nama:** Tiara Febrianie
* **NIM:** 244107020097
* **Kelas:** TI-3I
* **Program Studi:** D4 Teknik Informatika, Jurusan Teknologi Informasi
* **Institusi:** Politeknik Negeri Malang (Polinema)

---

## 1. Audit Riwayat Git & Simulasi Rewrite Commit

Dalam audit riwayat commit repositori sebelumnya (Weeks 1–7), ditemukan beberapa commit yang terlalu singkat (*vague*), tidak mencantumkan lingkup modul (*scope*), atau tidak mendeskripsikan dampak perubahan secara jelas.

### Tabel Perbaikan Commit (Sebelum vs Sesudah):

| Hash / Commit Awal | Format Lama (Vague / Non-Conventional) | Format Perbaikan (Conventional Commits) | Rasional & Nilai Tambah |
|---|---|---|---|
| `7e0813a` | `Add week 3 todo app` | `feat(todo): implement riverpod async state management and filter logic` | Menjelaskan secara spesifik bahwa fitur yang ditambahkan adalah manajemen state asinkron Riverpod dan logika filter, bukan sekadar "add app". |
| `3ed1df9` | `Add week 6 auth FCM` | `feat(auth): integrate secure storage for jwt and fcm push notification lifecycle` | Memperjelas bahwa pekerjaan mencakup penyimpanan aman token JWT di KeyStore/Keychain dan penanganan siklus hidup token push notification FCM. |
| `8b785b1` | `Complete week 7 clean architecture` | `refactor(architecture): decouple features into feature-first clean architecture layers` | Menandai perubahan sebagai refaktor arsitektur (bukan penambahan fitur baru) dan menegaskan pemisahan layer presentation, domain, dan data. |

---

## 2. Pemodelan Cabang GitFlow (*Branching Strategy*)

Untuk mencegah benturan kode dan menjaga stabilitas rilis:

| Nama Cabang | Peran & Hak Akses | Aturan & Kebijakan (*Branch Rules*) |
|---|---|---|
| **`main`** | Versi produksi / rilis resmi (*Always Releasable*) | Dilarang melakukan commit langsung (*direct commit protected*). Hanya menerima *merge commit* dari `develop` atau `hotfix/*` setelah lolos review dan audit pengujian. |
| **`develop`** | Cabang integrasi fitur mingguan | Menjadi basis percabangan semua fitur baru dan target default seluruh Pull Request. |
| **`feature/*`** | Pengembangan fitur tunggal harian | Dibuat dari `develop` (misal: `feat/notes-validation`), berumur pendek (< 3 hari), dan ditutup setelah di-merge. |
| **`fix/*`** | Perbaikan bug teridentifikasi | Dilengkapi langkah reproduksi masalah dan unit test yang membuktikan bug teratasi. |

---

## 3. Templat Pull Request Standar (PR Template)

Setiap pengajuan Pull Request wajib mengisi templat berikut:

```markdown
### Judul: feat(notes): validate empty title + sanitize input

### Masalah (Problem)
Pengguna dapat menyimpan catatan kosong tanpa judul atau hanya berisi spasi kosong (whitespace). Hal ini memicu record tidak valid pada basis data lokal SQLite dan tampilan daftar catatan menjadi rusak.

### Solusi (Solution)
- Menambahkan aturan validasi bisnis pada Use Case `ValidateNoteTitle` di lapisan domain.
- Mengembalikan `ValidationFailure('Judul catatan tidak boleh kosong.')` jika judul hanya berisi spasi.
- Menghubungkan state validasi ke UI form catatan dengan pesan error berwarna merah di bawah TextField.

### Langkah Pengujian (Test Steps)
1. Buka dialog tambah catatan -> ketik hanya spasi -> tekan Simpan -> SnackBar / Text error muncul.
2. Jalankan automated test: `flutter test test/clean_architecture_test.dart`.

### Issue Terkait
Closes #12
```

---

## 4. Daftar Periksa Peer Review (Observation → Impact → Concrete Proposal)

Peer review kode dilakukan antar mahasiswa menggunakan pola umpan balik konstruktif:

1. **Temuan Kebenaran 1 (Correctness):**
   * *Observation:* Input field judul hanya diperiksa dengan `title.isEmpty`, belum memeriksa `title.trim().isEmpty`.
   * *Impact:* Pengguna masih bisa menekan spasi beberapa kali untuk mengelabui validasi.
   * *Proposal:* Ubah kondisi pengecekan menjadi `if (title.trim().isEmpty)`.
2. **Temuan Kebenaran 2 (Correctness):**
   * *Observation:* State loading pada tombol simpan tidak menonaktifkan tombol (`onPressed: null`).
   * *Impact:* Pengguna dapat mengetuk tombol berkali-kali (*double tap*), memicu duplikasi record catatan di database.
   * *Proposal:* Set `onPressed: isLoading ? null : _submit`.
3. **Temuan Arsitektur (Architecture):**
   * *Observation:* Validasi judul sebelumnya diletakkan di dalam `onPressed` widget button.
   * *Impact:* Logika validasi terikat dengan Flutter UI dan tidak bisa diuji pada unit test murni tanpa widget tester.
   * *Proposal:* Pindahkan fungsi validasi ke dalam Use Case di lapisan `domain/usecases/`.
4. **Temuan Kesenjangan Pengujian (Test Gap):**
   * *Observation:* Unit test baru menguji kasus string kosong (`""`), belum menguji string berisi whitespace (`"   "`).
   * *Impact:* Potensi regresi jika ada perubahan logika sanitasi string.
   * *Proposal:* Tambahkan test case `test('returns failure when title contains only whitespace')`.
5. **Saran Keterbacaan (Readability):**
   * *Observation:* Pesan error di-hardcode langsung di beberapa file visual.
   * *Proposal:* Kumpulkan konstanta string pesan kesalahan ke dalam class failure `core/failures.dart`.

**Keputusan Akhir Reviewer:** **REQUEST CHANGES** pada putaran pertama → Perbaikan diaplikasikan dan diuji → **APPROVED & MERGED**.
