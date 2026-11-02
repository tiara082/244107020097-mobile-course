import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_providers.dart';
import '../widgets/note_card.dart';
import '../widgets/search_empty_view.dart';

class NotesSearchPage extends ConsumerStatefulWidget {
  const NotesSearchPage({super.key});

  @override
  ConsumerState<NotesSearchPage> createState() => _NotesSearchPageState();
}

class _NotesSearchPageState extends ConsumerState<NotesSearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final notes = ref.watch(filteredNotesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Kampus (Pencarian AI)'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              controller: _controller,
              hintText: 'Cari judul, isi, atau kategori...',
              leading: const Icon(Icons.search),
              trailing: query.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      ),
                    ]
                  : null,
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).state = val;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Text(
                  query.isEmpty
                      ? 'Semua Catatan (${notes.length})'
                      : 'Hasil Pencarian (${notes.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? SearchEmptyView(
                    query: query,
                    onReset: query.isNotEmpty ? _clearSearch : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return NoteCard(note: notes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
