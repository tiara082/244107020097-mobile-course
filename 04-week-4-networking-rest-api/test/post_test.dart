import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository({this.items, this.throwError = false}) : super(Dio());
  final List<Post>? items;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }

  @override
  Future<List<Post>> fetchPostsPage({
    required int page,
    int limit = 10,
  }) async {
    return fetchPosts();
  }
}

void main() {
  group('Post and Comment Model Deserialization', () {
    test('Post.fromJson is safe against missing fields', () {
      final post = Post.fromJson({'id': 7});
      expect(post.id, 7);
      expect(post.title, '');
      expect(post.userId, 0);
      expect(post.body, '');
    });

    test('Comment.fromJson is safe against missing fields', () {
      final comment = Comment.fromJson({'id': 10, 'postId': 1});
      expect(comment.id, 10);
      expect(comment.postId, 1);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });
  });

  group('Network Error Mapping', () {
    test('friendlyErrorMessage for connection error', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
      expect(friendlyErrorMessage(err), contains('reach'));
    });

    test('friendlyErrorMessage for timeout error', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(friendlyErrorMessage(err), contains('timeout'));
    });

    test('friendlyErrorMessage for 404 response', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/posts'),
          statusCode: 404,
        ),
      );
      expect(friendlyErrorMessage(err), contains('404'));
    });
  });

  group('PostListProvider with Fake Repository', () {
    test('provider succeeds with a fake repository', () async {
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(items: [
              const Post(
                userId: 1,
                id: 1,
                title: 'Test Post',
                body: 'Body content',
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final posts = await readPostsOnce(container);
      expect(posts.length, 1);
      expect(posts.first.title, 'Test Post');
    });

    test('provider errors with a fake repository', () async {
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(throwError: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final err = await readPostsErrorOnce(container);
      expect(err, isA<DioException>());
      expect(friendlyErrorMessage(err!), contains('reach'));
    });
  });
}
