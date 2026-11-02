import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/feed_provider.dart';

class MetricsCounterHeader extends ConsumerWidget {
  const MetricsCounterHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Isolated rebuilds using granular Riverpod select providers
    final totalLikes = ref.watch(feedTotalLikesProvider);
    final itemsCount = ref.watch(feedItemsCountProvider);
    final repo = ref.watch(feedRepositoryProvider);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, color: Colors.indigo.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Performa Feed JTI Polinema (60 FPS)',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Artikel',
                    value: '$itemsCount',
                    icon: Icons.article_outlined,
                  ),
                ),
                Expanded(
                  child: _StatCard(
                    label: 'Suka',
                    value: '$totalLikes',
                    icon: Icons.favorite_border,
                  ),
                ),
                Expanded(
                  child: _StatCard(
                    label: 'Cache Hits',
                    value: '${repo.cacheHits}',
                    icon: Icons.storage_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.indigo.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
