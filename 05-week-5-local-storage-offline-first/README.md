# Week 5: Local Storage & Offline-First (SQLite & SharedPreferences)

## Student Details
* **Name:** Tiara Febrianie
* **Student ID (NIM):** 244107020097
* **Class:** TI-3I
* **Department:** Information Technology - State Polytechnic of Malang (Polinema)


---

* The app bar dynamically reflects the sync queue size with a badge (e.g. `2 Belum Sync`).
* Tapping the **Sinkronisasi** button triggers `syncNotes()`:
  1. Identifies all notes where `dirty = 1`.
  2. Simulates network transmission with payload logging.
  3. Executes an atomic batch update marking them `dirty = 0`.
  4. Invalidates the notes provider and displays a success notification with the synchronized note count.

### 3. Cache-First Post Reader
* In addition to notes, `db.dart` provides a `cached_posts` table allowing REST API posts from Week 4 to be cached locally.
* On app launch, cached posts render instantly from SQLite, eliminating white-screen latency while background fetching occurs.

### 4. Conflict Resolution Strategy: Last-Write-Wins (LWW)
* Every note entity carries an `updated_at` timestamp stored in UTC.
* During bidirectional sync, if a note has been modified both locally and on the server, the record with the higher (more recent) timestamp takes precedence, ensuring the user's latest work is preserved without silent data loss.

