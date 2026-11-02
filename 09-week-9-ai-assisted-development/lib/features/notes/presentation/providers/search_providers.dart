import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/note.dart';
import '../../domain/usecases/search_notes.dart';

final sampleNotes = [
  Note(
    id: '1',
    title: 'Praktikum Mobile Pemrograman',
    body: 'Mempelajari arsitektur Clean Architecture, Riverpod, dan SQLite.',
    category: 'Kuliah',
    updatedAt: DateTime(2026, 10, 18),
  ),
  Note(
    id: '2',
    title: 'Jadwal Kuliah dan Ruang Kelas',
    body: 'Perkuliahan hari Rabu dipindahkan ke Gedung Sipil Ruang S3.',
    category: 'Akademik',
    updatedAt: DateTime(2026, 10, 19),
  ),
  Note(
    id: '3',
    title: 'Daftar Belanja Kebutuhan Kos',
    body: 'Beli deterjen, sabun cuci, pasta gigi, dan kopi sachet.',
    category: 'Pribadi',
    updatedAt: DateTime(2026, 10, 20),
  ),
  Note(
    id: '4',
    title: 'Persiapan Evaluasi UTS Mobile',
    body: 'Memeriksa code review checklist dan verifikasi prompt AI.',
    category: 'Ujian',
    updatedAt: DateTime(2026, 10, 21),
  ),
];

final searchNotesUseCaseProvider = Provider<SearchNotes>((ref) => const SearchNotes());

final searchQueryProvider = StateProvider<String>((ref) => '');

final notesListProvider = Provider<List<Note>>((ref) => sampleNotes);

final filteredNotesProvider = Provider<List<Note>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final notes = ref.watch(notesListProvider);
  final searchUseCase = ref.watch(searchNotesUseCaseProvider);

  return searchUseCase.call(notes: notes, query: query);
});
