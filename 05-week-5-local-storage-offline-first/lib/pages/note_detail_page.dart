import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteDetailProvider(noteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
      ),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Gagal memuat catatan: $err'),
        ),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    if (note.dirty)
                      Chip(
                        avatar: const Icon(Icons.sync_problem, size: 16),
                        label: const Text('Unsynced'),
                        backgroundColor: Colors.amber.shade100,
                      )
                    else
                      Chip(
                        avatar: const Icon(Icons.cloud_done, size: 16),
                        label: const Text('Synced'),
                        backgroundColor: Colors.green.shade100,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Terakhir diperbarui: ${note.updatedAt.toLocal()}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(height: 32),
                Text(
                  note.body.isNotEmpty ? note.body : '(Tidak ada isi konten)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
