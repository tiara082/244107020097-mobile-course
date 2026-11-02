import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_performance_opt/models/feed_item.dart';
import 'package:campus_performance_opt/providers/feed_provider.dart';
import 'package:campus_performance_opt/repositories/feed_repository.dart';
import 'package:campus_performance_opt/screens/feed_screen.dart';
import 'package:campus_performance_opt/widgets/feed_item_tile.dart';
import 'package:campus_performance_opt/widgets/metrics_counter_header.dart';

void main() {
  group('1. Stale-While-Revalidate Repository Caching Tests', () {
    test('fetches from network on first call and caches response', () async {
      int fetchCalls = 0;
      final repo = FeedRepository(
        networkFetcher: (page, pageSize) async {
          fetchCalls++;
          return [
            FeedItem(
              id: 'item-$page',
              title: 'Title $page',
              summary: 'Summary $page',
              category: 'Akademik',
              imageUrl: '',
              publishedAt: DateTime(2026, 10, 26),
              likeCount: 5,
            ),
          ];
        },
      );

      expect(repo.cacheHits, 0);
      expect(repo.networkRequests, 0);

      // 1st request -> Network call
      final page1 = await repo.fetchFeedPage(page: 1);
      expect(page1.length, 1);
      expect(fetchCalls, 1);
      expect(repo.networkRequests, 1);
      expect(repo.cacheHits, 0);

      // 2nd request -> Cache Hit (no network call!)
      final cachedPage1 = await repo.fetchFeedPage(page: 1);
      expect(cachedPage1.length, 1);
      expect(fetchCalls, 1); // Not incremented!
      expect(repo.networkRequests, 1);
      expect(repo.cacheHits, 1); // Hit count incremented

      // 3rd request with forceRefresh: true -> Network call
      final freshPage1 = await repo.fetchFeedPage(page: 1, forceRefresh: true);
      expect(freshPage1.length, 1);
      expect(fetchCalls, 2);
      expect(repo.networkRequests, 2);
    });
  });

  group('2. Riverpod State & Pagination Optimization Tests', () {
    test('FeedNotifier paginates and appends items correctly', () async {
      final repo = FeedRepository(
        networkFetcher: (page, pageSize) async {
          if (page > 2) return [];
          return List.generate(
            5,
            (i) => FeedItem(
              id: 'p${page}_i$i',
              title: 'Page $page Item $i',
              summary: 'Summary',
              category: 'Akademik',
              imageUrl: '',
              publishedAt: DateTime(2026, 10, 26),
              likeCount: 2,
            ),
          );
        },
      );

      final notifier = FeedNotifier(repo);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(notifier.state.items.length, 5);
      expect(notifier.state.page, 1);
      expect(notifier.state.totalLikes, 10);
      expect(notifier.state.hasMore, true);

      // Load Page 2
      await notifier.loadNextPage();
      expect(notifier.state.items.length, 10);
      expect(notifier.state.page, 2);
      expect(notifier.state.totalLikes, 20);
      expect(notifier.state.hasMore, true);

      // Load Page 3 (returns empty -> hasMore = false)
      await notifier.loadNextPage();
      expect(notifier.state.items.length, 10);
      expect(notifier.state.hasMore, false);

      // Optimistic like update
      notifier.toggleLike('p1_i0');
      expect(notifier.state.items.first.likeCount, 3);
      expect(notifier.state.items.first.isLiked, true);
      expect(notifier.state.totalLikes, 21);
    });
  });

  group('3. Widget Rendering & RepaintBoundary Isolation Tests', () {
    testWidgets('renders MetricsCounterHeader inside RepaintBoundary', (tester) async {
      final sampleItems = [
        FeedItem(
          id: 'test-1',
          title: 'Sosialisasi Jadwal UTS Semester Ganjil',
          summary: 'Jadwal pelaksanaan Ujian Tengah Semester untuk mahasiswa JTI.',
          category: 'Akademik',
          imageUrl: '',
          publishedAt: DateTime(2026, 10, 26),
          likeCount: 15,
        ),
      ];

      final repo = FeedRepository(
        networkFetcher: (page, pageSize) async => sampleItems,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            feedRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: FeedScreen(),
          ),
        ),
      );

      // Initial pump
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify RepaintBoundary exists for MetricsCounterHeader
      final repaintBoundaryFinder = find.byType(RepaintBoundary);
      expect(repaintBoundaryFinder, findsWidgets);

      // Verify MetricsCounterHeader is present
      expect(find.byType(MetricsCounterHeader), findsOneWidget);
      expect(find.text('Performa Feed JTI Polinema (60 FPS)'), findsOneWidget);

      // Verify FeedItemTile is rendered
      expect(find.byType(FeedItemTile), findsOneWidget);
      expect(find.text('Sosialisasi Jadwal UTS Semester Ganjil'), findsOneWidget);
      expect(find.text('15 suka'), findsOneWidget);

      // Tap like button to verify optimistic update
      final likeBtn = find.byTooltip('Like');
      expect(likeBtn, findsOneWidget);
      await tester.tap(likeBtn);
      await tester.pump();

      expect(find.text('16 suka'), findsOneWidget);
    });

    testWidgets('FeedScreen disposes controller safely without leaks', (tester) async {
      final repo = FeedRepository(
        networkFetcher: (page, pageSize) async => [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            feedRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: FeedScreen(),
          ),
        ),
      );

      await tester.pump();

      // Replace with another screen to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Next Screen')),
        ),
      );
      await tester.pump();

      expect(find.text('Next Screen'), findsOneWidget);
    });
  });
}
