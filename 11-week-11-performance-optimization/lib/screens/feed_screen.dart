import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/feed_provider.dart';
import '../widgets/feed_item_tile.dart';
import '../widgets/metrics_counter_header.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedNotifierProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    // Prevent memory leaks: always dispose controllers and listeners
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedNotifierProvider);
    final notifier = ref.read(feedNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Campus Feed & Optimization',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
            tooltip: 'Force Revalidate Cache',
          ),
        ],
      ),
      body: state.isLoading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: notifier.refresh,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: MetricsCounterHeader(),
                  ),
                  if (state.items.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'Belum ada pengumuman kampus.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    // Lazy loading list: only visible viewport items are built
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == state.items.length) {
                            return state.hasMore
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: Text(
                                        'Semua pengumuman telah dimuat.',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  );
                          }

                          final item = state.items[index];
                          return FeedItemTile(
                            key: ValueKey(item.id),
                            item: item,
                            onLike: () => notifier.toggleLike(item.id),
                          );
                        },
                        childCount: state.items.length + 1,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
