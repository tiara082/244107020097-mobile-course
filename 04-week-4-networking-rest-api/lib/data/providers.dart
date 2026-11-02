import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'models/comment.dart';
import 'models/post.dart';
import 'repositories/comment_repository.dart';
import 'repositories/post_repository.dart';

export 'network_errors.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(postRepositoryProvider);
      state = AsyncData(await repository.fetchPosts());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final postListProvider =
    AsyncNotifierProvider<PostListNotifier, List<Post>>(
  PostListNotifier.new,
);

final postDetailProvider =
    FutureProvider.family<Post, int>((ref, id) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.fetchPostDetail(id);
});

final commentsProvider =
    FutureProvider.family<List<Comment>, int>((ref, postId) async {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});

Future<List<Post>> readPostsOnce(ProviderContainer container) async {
  final completer = Completer<List<Post>>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next is AsyncData<List<Post>>) {
        if (!completer.isCompleted) completer.complete(next.value);
      } else if (next is AsyncError<List<Post>>) {
        if (!completer.isCompleted) {
          completer.completeError(next.error, next.stackTrace);
        }
      }
    },
    fireImmediately: true,
  );
  try {
    return await completer.future;
  } finally {
    sub.close();
  }
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) async {
  final completer = Completer<Object?>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next is AsyncError<List<Post>>) {
        if (!completer.isCompleted) completer.complete(next.error);
      } else if (next is AsyncData<List<Post>>) {
        if (!completer.isCompleted) completer.complete(null);
      }
    },
    fireImmediately: true,
  );
  try {
    return await completer.future;
  } finally {
    sub.close();
  }
}
