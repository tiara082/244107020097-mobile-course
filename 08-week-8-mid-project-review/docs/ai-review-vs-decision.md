# AI Code Review vs Human Decision — Week 8: Mid-Project Review

Dokumentasi evaluasi kritis terhadap hasil tinjauan kode otomatis dari AI coding assistant (*AI Code Reviewer*), pembuktian bukti temuan, dan justifikasi keputusan teknis mahasiswa.

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
Review this Flutter PR as a senior Flutter dev.
Context: feature-first Clean Architecture
(presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Focus: correctness, architecture, tests. Ignore style.
Give the top 5 findings + severity (blocker/suggestion)
+ rationale + proposed code fix.
```

---

## 2. Lima Temuan Utama AI & Matriks Evaluasi (AI Verification Checklist)

| No | Temuan AI | Tingkat Keparahan (*Severity*) | Rasional AI | Keputusan Mahasiswa | Justifikasi & Pembuktian Teknis |
|---|---|---|---|---|---|
| **1** | Validasi string judul hanya menggunakan `.isEmpty` sehingga karakter spasi (`"   "`) lolos validasi | **Blocker** | Nilai string hanya spasi memicu judul kosong tak terbaca pada database lokal SQLite | **DITERIMA** | Terbukti via unit test. Diperbaiki dengan sanitasi `.trim().isEmpty` pada domain use case. |
| **2** | Logika validasi ditaruh langsung di callback tombol `onPressed` UI | **Blocker** | Melanggar aturan Clean Architecture; validasi adalah aturan bisnis yang harus dapat diuji tanpa widget | **DITERIMA** | Terbukti melanggar Single Responsibility. Validasi dipindahkan ke class `ValidateNoteTitle` di lapisan domain. |
| **3** | Pengujian unit belum menguji kasus kegagalan string whitespace | **Suggestion** | Ketiadaan negative test case berisiko menimbulkan regresi pada perubahan masa depan | **DITERIMA** | Test case baru ditambahkan pada unit test untuk memastikan kegagalan terdeteksi secara konsisten. |
| **4** | Menyarankan use case menerima `BuildContext` agar bisa langsung menampilkan `ScaffoldMessenger.showSnackBar` | **Blocker (Usulan AI)** | AI beralasan agar kode UI lebih ringkas tanpa perlu mengecek status failure | **DITOLAK KERAS** | **Pelanggaran Arsitektur Fatal!** Lapisan domain dilarang keras mengimpor `package:flutter` atau menyentuh `BuildContext`. Presentasi yang bertanggung jawab merespons failure dari use case. |
| **5** | Mengusulkan instalasi package fungsional eksternal (`fpdart`) untuk tipe `Either<Failure, Success>` | **Suggestion** | Menurut AI, functional programming lebih elegan dibanding Dart records | **DITOLAK & DISEDERHANAKAN** | Fitur bawaan **Dart 3 Records** (`({Success? data, Failure? failure})`) sudah sangat type-safe dan tidak memerlukan dependensi eksternal tambahan (*zero external bloat*). |

---

## 3. Analisis Kritis: Mengapa Keputusan Manusia Mengungguli Review Buta AI

1. **AI Rentan Menyarankan Pola yang Merusak Arsitektur (Anti-Pattern):**
   * Pada temuan nomor 4, AI mengusulkan agar Use Case langsung memanggil SnackBar dengan mengoper `BuildContext`. Jika saran ini diterima mentah-mentah (*blind acceptance*), lapisan Domain akan tercemar oleh framework Flutter UI, melanggar *Dependency Rule* Clean Architecture dan menyebabkan unit test use case menjadi gagal total.
2. **AI Cenderung Menyarankan Over-Engineering Library Pihak Ketiga:**
   * Pada temuan nomor 5, AI mengarahkan pengembang untuk menambahkan library `fpdart`. Sebagai mahasiswa teknik informatika yang bertanggung jawab, kita harus mempertimbangkan efisiensi ukuran aplikasi (*APK size*) dan memprioritaskan fitur bawaan modern dari bahasa Dart 3.
3. **Akuntabilitas Teknis:**
   * AI adalah alat bantu akselerasi penemu celah awal (*first-pass scanner*), tetapi keputusan akhir dan tanggung jawab kelayakan kode tetap berada sepenuhnya di tangan pengembang perangkat lunak (*human in the loop*).
