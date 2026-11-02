import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Preferensi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tema Tampilan (Dark Mode)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      darkModeAsync.when(
                        loading: () => const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const Icon(Icons.error, color: Colors.red),
                        data: (isDark) => Switch.adaptive(
                          value: isDark,
                          onChanged: (_) =>
                              ref.read(darkModeProvider.notifier).toggle(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pengaturan tema disimpan langsung ke SharedPreferences secara lokal.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history_toggle_off),
              title: const Text(
                'Terakhir Dibuka (last_opened_at)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: lastOpenedAsync.when(
                loading: () => const Text('Memuat...'),
                error: (e, _) => Text('Gagal: $e'),
                data: (time) => Text(
                  time ?? 'Belum pernah dicatat',
                  style: const TextStyle(color: Colors.indigo),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arsitektur Offline-First (Week 5)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• SharedPreferences: Khusus primitive key-value (Tema, Waktu Terakhir).\n'
                    '• SQLite (sqflite): Penyimpanan relasional lokal untuk koleksi Catatan.\n'
                    '• Dirty Flag: Menandai catatan yang belum tersinkronisasi (dirty = 1).\n'
                    '• Cache-First: Menampilkan data lokal terlebih dahulu saat dibuka tanpa internet.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
