import 'dart:async';
import '../models/feed_item.dart';

abstract class IFeedRepository {
  Future<List<FeedItem>> fetchFeedPage({
    required int page,
    int pageSize = 10,
    bool forceRefresh = false,
  });

  void clearCache();
  int get cacheHits;
  int get networkRequests;
}

class FeedRepository implements IFeedRepository {
  FeedRepository({
    Future<List<FeedItem>> Function(int page, int pageSize)? networkFetcher,
  }) : _networkFetcher = networkFetcher ?? _defaultMockFetcher;

  final Future<List<FeedItem>> Function(int page, int pageSize) _networkFetcher;

  final Map<int, List<FeedItem>> _cache = {};
  int _cacheHits = 0;
  int _networkRequests = 0;

  @override
  int get cacheHits => _cacheHits;

  @override
  int get networkRequests => _networkRequests;

  @override
  void clearCache() {
    _cache.clear();
  }

  @override
  Future<List<FeedItem>> fetchFeedPage({
    required int page,
    int pageSize = 10,
    bool forceRefresh = false,
  }) async {
    // 1. Check local cache (Stale-While-Revalidate pattern)
    if (!forceRefresh && _cache.containsKey(page)) {
      _cacheHits++;
      return List<FeedItem>.unmodifiable(_cache[page]!);
    }

    // 2. Fetch fresh data from network datasource
    _networkRequests++;
    final freshItems = await _networkFetcher(page, pageSize);

    // 3. Update cache
    _cache[page] = freshItems;

    return List<FeedItem>.unmodifiable(freshItems);
  }

  static Future<List<FeedItem>> _defaultMockFetcher(int page, int pageSize) async {
    // Simulate real network latency (50ms)
    await Future<void>.delayed(const Duration(milliseconds: 50));

    if (page > 3) {
      // Limit to 3 pages total for demo pagination
      return [];
    }

    final categories = ['Akademik', 'Beasiswa', 'Workshop', 'Kemahasiswaan'];
    final startIndex = (page - 1) * pageSize;

    return List.generate(pageSize, (index) {
      final itemIndex = startIndex + index + 1;
      final category = categories[itemIndex % categories.length];
      return FeedItem(
        id: 'feed-$itemIndex',
        title: 'Pengumuman JTI Polinema #$itemIndex: Sosialisasi $category',
        summary:
            'Informasi penting terkait agenda perkuliahan, pedoman praktikum mobile, dan kegiatan $category di jurusan Teknologi Informasi.',
        category: category,
        imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500&q=80',
        publishedAt: DateTime(2026, 10, 26, 8, 0).subtract(Duration(hours: itemIndex * 2)),
        likeCount: (itemIndex * 7) % 50,
      );
    });
  }
}
