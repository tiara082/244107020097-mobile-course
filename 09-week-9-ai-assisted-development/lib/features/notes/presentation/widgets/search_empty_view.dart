import 'package:flutter/material.dart';

class SearchEmptyView extends StatelessWidget {
  const SearchEmptyView({
    required this.query,
    this.onReset,
    super.key,
  });

  final String query;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 56,
                color: Colors.indigo.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tidak ada catatan yang cocok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              query.isEmpty
                  ? 'Belum ada catatan yang tersimpan.'
                  : 'Tidak ditemukan hasil pencarian untuk "$query". Coba gunakan kata kunci lain.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (query.isNotEmpty && onReset != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Hapus Pencarian'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
