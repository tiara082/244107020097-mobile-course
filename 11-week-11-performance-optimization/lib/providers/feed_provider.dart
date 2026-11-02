import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/feed_item.dart';
import '../repositories/feed_repository.dart';

final feedRepositoryProvider = Provider<IFeedRepository>((ref) {
  return FeedRepository();
});

@immutable
class FeedState {
  const FeedState({
    this.items = const [],
    this.page = 1,
    this.isLoading = false,
    this.isFetchingMore = false,
    this.hasMore = true,
    this.totalLikes = 0,
    this.errorMessage,
  });

  final List<FeedItem> items;
  final int page;
  final bool isLoading;
  final bool isFetchingMore;
  final bool hasMore;
  final int totalLikes;
  final String? errorMessage;

  FeedState copyWith({
    List<FeedItem>? items,
    int? page,
    bool? isLoading,
    bool? isFetchingMore,
    bool? hasMore,
    int? totalLikes,
    String? errorMessage,
  }) {
    return FeedState(
      items: items ?? this.items,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMore: hasMore ?? this.hasMore,
      totalLikes: totalLikes ?? this.totalLikes,
      errorMessage: errorMessage,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier(this._repository) : super(const FeedState()) {
    loadInitial();
  }

  final IFeedRepository _repository;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final initialItems = await _repository.fetchFeedPage(page: 1);
      final likes = initialItems.fold<int>(0, (sum, item) => sum + item.likeCount);

      state = state.copyWith(
        items: initialItems,
        page: 1,
        isLoading: false,
        hasMore: initialItems.isNotEmpty,
        totalLikes: likes,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat feed: $e',
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isFetchingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isFetchingMore: true);
    final nextPage = state.page + 1;

    try {
      final newItems = await _repository.fetchFeedPage(page: nextPage);
      if (newItems.isEmpty) {
        state = state.copyWith(
          isFetchingMore: false,
          hasMore: false,
        );
      } else {
        final combined = [...state.items, ...newItems];
        final likes = combined.fold<int>(0, (sum, item) => sum + item.likeCount);

        state = state.copyWith(
          items: combined,
          page: nextPage,
          isFetchingMore: false,
          hasMore: true,
          totalLikes: likes,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isFetchingMore: false,
        errorMessage: 'Gagal memuat halaman $nextPage: $e',
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final freshItems = await _repository.fetchFeedPage(page: 1, forceRefresh: true);
      final likes = freshItems.fold<int>(0, (sum, item) => sum + item.likeCount);

      state = state.copyWith(
        items: freshItems,
        page: 1,
        isLoading: false,
        hasMore: true,
        totalLikes: likes,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal refresh feed: $e',
      );
    }
  }

  void toggleLike(String itemId) {
    final updatedList = state.items.map((item) {
      if (item.id == itemId) {
        final newIsLiked = !item.isLiked;
        final newCount = newIsLiked ? item.likeCount + 1 : item.likeCount - 1;
        return item.copyWith(isLiked: newIsLiked, likeCount: newCount);
      }
      return item;
    }).toList();

    final newTotalLikes = updatedList.fold<int>(0, (sum, item) => sum + item.likeCount);
    state = state.copyWith(items: updatedList, totalLikes: newTotalLikes);
  }
}

final feedNotifierProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return FeedNotifier(repository);
});

// Granular Riverpod selectors (avoids rebuilding entire list when only stats change)
final feedTotalLikesProvider = Provider<int>((ref) {
  return ref.watch(feedNotifierProvider.select((s) => s.totalLikes));
});

final feedItemsCountProvider = Provider<int>((ref) {
  return ref.watch(feedNotifierProvider.select((s) => s.items.length));
});

final feedIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(feedNotifierProvider.select((s) => s.isLoading));
});
