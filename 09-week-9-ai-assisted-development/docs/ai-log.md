# AI Development Log & Prompt Engineering — Week 9: AI-Assisted Development / Vibe Coding

Dokumentasi proses rekayasa prompt (*prompt engineering*), draf kode awal AI, temuan halusinasi, checklist verifikasi 6 langkah, dan matriks keputusan teknis.

---

## 👨‍🎓 Student Details
* **Nama:** Tiara Febrianie
* **NIM:** 244107020097
* **Kelas:** TI-3I
* **Program Studi:** D4 Teknik Informatika, Jurusan Teknologi Informasi
* **Institusi:** Politeknik Negeri Malang (Polinema)

---

## 1. Prompt Inti dengan Formula 5-Slot (*Five-Slot Prompting Formula*)

```text
[ROLE]
Act as a senior Flutter developer and mobile software architect.

[CONTEXT]
We have a Flutter project structured using feature-first Clean Architecture (presentation -> domain <- data) with Riverpod for state management. We store notes entities with id, title, body, updatedAt, and category.

[TASK]
Implement notes title search with real-time filtering and a dedicated empty state when no notes match the query.

[LIMITS]
- Do not put search logic inside the UI widget tree or call setState.
- Filter logic must live inside a pure domain use case (SearchNotes) without Flutter imports.
- Use Riverpod providers for search query and filtered list state.
- Keep use case code concise (< 50 lines).
- No hardcoded secrets, tokens, or cross-layer leaks.

[OUTPUT]
Provide:
1. Pure domain use case (SearchNotes).
2. Riverpod providers wiring.
3. Clean UI page with SearchBar and EmptyStateView.
4. Unit & widget tests covering empty query, matching title/body, and non-matching empty state.
```

---

## 2. Draf Awal AI & Temuan Halusinasi

### Temuan Halusinasi & Kode Bermasalah pada Draf AI:
1. **Pencampuran Layer (Layer Bleeding):**
   Pada draf awalnya, AI menghasilkan widget `StatefulWidget` dengan `setState()` dan melakukan manipulasi list langsung di dalam method `build()`. Hal ini melanggar batasan prompt dan menghancurkan prinsip Clean Architecture.
2. **Halusinasi API & Parameter Tak Valid:**
   AI mencoba memanggil `SearchBar(trailing: [Icon(Icons.clear, onPressed: ...)])`. Di Flutter, widget `Icon` tidak memiliki properti `onPressed` (yang benar adalah `IconButton`).
3. **Pengabaian Sanitasi Query (Whitespace Bug):**
   AI hanya menuliskan `note.title.contains(query)`. Jika pengguna mengetik huruf kapital ("KULIAH") atau menambahkan spasi di akhir query ("kuliah "), pencarian gagal menemukan hasil karena tidak ada sanitasi `.trim()` dan `.toLowerCase()`.

---

## 3. Checklist Verifikasi 6 Langkah (*Six-Step Verification*)

| Langkah Verifikasi | Prosedur Pengujian | Hasil Audit | Status |
|---|---|---|---|
| **1. Pembacaan Baris per Baris** | Meninjau seluruh kode dan menandai bagian yang tidak jelas | Menemukan penggunaan `Icon` yang salah dan ketiadaan `.trim()` | ✅ Diverifikasi |
| **2. Sterilitas Impor Domain** | Memastikan `domain/usecases/search_notes.dart` bebas dari `package:flutter` | 0 impor Flutter / external library pada layer domain | ✅ Lulus |
| **3. Validasi API Resmi** | Memeriksa autocomplete Flutter SDK & pub.dev | Mengganti `Icon` menjadi `IconButton` pada tombol clear pencarian | ✅ Diperbaiki |
| **4. Analisis Statis** | Menjalankan `flutter analyze` hingga 0 issue | `No issues found! (ran in 60.0s)` | ✅ Lulus |
| **5. Pengujian Otomatis** | Menguji skenario query kosong, match case-insensitive, dan empty state | 7/7 unit & widget tests passed (`search_filter_test.dart`) | ✅ Lulus |
| **6. Pengujian Manual** | Memeriksa 3 skenario UI nyata (default, match query "Mobile", empty state) | Render visual berjalan mulus sesuai rancangan | ✅ Lulus |

---

## 4. Matriks Evaluasi: Usulan AI vs Keputusan Mahasiswa

| Komponen Kode | Draf Usulan Awal AI | Keputusan Mahasiswa | Alasan & Rasional Teknis |
|---|---|---|---|
| **Lokasi Logika Filter** | Filter ditaruh di dalam `_NotesPageState` menggunakan `setState` | **Ditolak & Dipisahkan**: Dibuatkan Use Case murni `SearchNotes` di `domain/` | Menjaga Single Responsibility. Logika pencarian dapat diuji dalam unit test murni tanpa perlu mem-pump widget. |
| **Manajemen State Pencarian** | Menggunakan variabel lokal controller | **Diterima & Ditingkatkan**: Menggunakan Riverpod `searchQueryProvider` + `filteredNotesProvider` | State pencarian menjadi reaktif dan dapat di-override dengan mudah dalam widget test. |
| **Penanganan Huruf Besar/Kecil & Spasi** | `contains(query)` langsung tanpa normalisasi | **Ditolak & Diperbaiki**: `query.trim().toLowerCase()` dan `note.title.toLowerCase()` | Mencegah bug pencarian tidak cocok akibat perbedaan kapitalisasi atau spasi tidak sengaja dari keyboard ponsel. |
| **Widget Empty State** | Hanya teks sederhana `Text('No results')` | **Ditingkatkan**: Dibuatkan komponen `SearchEmptyView` dengan icon informatif, pesan kontekstual, dan tombol reset query | Memberikan UX yang ramah bagi pengguna (*human-centered design*) saat pencarian tidak menemukan hasil. |
