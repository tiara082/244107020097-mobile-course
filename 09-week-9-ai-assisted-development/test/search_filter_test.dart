import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_search_ai/features/notes/domain/entities/note.dart';
import 'package:notes_search_ai/features/notes/domain/usecases/search_notes.dart';
import 'package:notes_search_ai/features/notes/presentation/pages/notes_search_page.dart';
import 'package:notes_search_ai/features/notes/presentation/widgets/search_empty_view.dart';

void main() {
  final testNotes = [
    Note(
      id: '1',
      title: 'Praktikum Mobile Pemrograman',
      body: 'Mempelajari Clean Architecture dan Riverpod.',
      category: 'Kuliah',
      updatedAt: DateTime(2026, 10, 18),
    ),
    Note(
      id: '2',
      title: 'Jadwal Kuliah',
      body: 'Ruang kelas dipindahkan ke S3.',
      category: 'Akademik',
      updatedAt: DateTime(2026, 10, 19),
    ),
    Note(
      id: '3',
      title: 'Daftar Belanja Kos',
      body: 'Beli deterjen dan sabun cuci.',
      category: 'Pribadi',
      updatedAt: DateTime(2026, 10, 20),
    ),
  ];

  group('SearchNotes UseCase Unit Tests', () {
    const useCase = SearchNotes();

    test('empty or whitespace query returns all original notes', () {
      final resEmpty = useCase.call(notes: testNotes, query: '');
      expect(resEmpty.length, 3);

      final resSpaces = useCase.call(notes: testNotes, query: '   ');
      expect(resSpaces.length, 3);
    });

    test('case-insensitive search matches title', () {
      final result = useCase.call(notes: testNotes, query: 'mobile');
      expect(result.length, 1);
      expect(result.first.id, '1');

      final upperResult = useCase.call(notes: testNotes, query: 'MOBILE');
      expect(upperResult.length, 1);
      expect(upperResult.first.id, '1');
    });

    test('search matches body text', () {
      final result = useCase.call(notes: testNotes, query: 'deterjen');
      expect(result.length, 1);
      expect(result.first.id, '3');
    });

    test('search matches category', () {
      final result = useCase.call(notes: testNotes, query: 'akademik');
      expect(result.length, 1);
      expect(result.first.id, '2');
    });

    test('non-matching query returns empty list', () {
      final result = useCase.call(notes: testNotes, query: 'xyz123tidakada');
      expect(result, isEmpty);
    });
  });

  group('NotesSearchPage Widget Tests', () {
    testWidgets('renders all notes on initial load', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: NotesSearchPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SearchBar), findsOneWidget);
      expect(find.text('Semua Catatan (4)'), findsOneWidget);
      expect(find.text('Praktikum Mobile Pemrograman'), findsOneWidget);
    });

    testWidgets('displays empty state when query finds no match', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: NotesSearchPage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(SearchBar), 'querytidakditemukan');
      await tester.pumpAndSettle();

      expect(find.byType(SearchEmptyView), findsOneWidget);
      expect(find.text('Tidak ada catatan yang cocok'), findsOneWidget);
      expect(find.text('Hasil Pencarian (0)'), findsOneWidget);
    });
  });
}
