import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/post/domain/repositories/post_repository.dart';
import 'package:fyx/features/post/presentation/viewmodel/post_replies_state.dart';
import 'package:fyx/features/post/presentation/viewmodel/post_replies_viewmodel.dart';
import 'package:fyx/model/Post.dart';

class _StubRepliesRepository implements PostRepository {
  final List<Post> replies;
  final bool throwError;
  final List<(int, int)> requests = [];

  _StubRepliesRepository({this.replies = const [], this.throwError = false});

  @override
  Future<List<Post>> getReplies({required int discussionId, required int postId}) async {
    requests.add((discussionId, postId));
    if (throwError) throw Exception('boom');
    return replies;
  }
}

class _FakePost implements Post {
  @override
  final int id;
  @override
  int idKlub = 42;

  _FakePost(this.id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('starts loading and ends with the replies', () async {
    final replies = [_FakePost(2), _FakePost(3)];
    final repo = _StubRepliesRepository(replies: replies);
    final vm = PostRepliesViewModel(repo);
    var notified = 0;
    vm.addListener(() => notified++);

    final future = vm.load(_FakePost(1));
    expect(vm.state.status, PostRepliesStatus.loading);
    expect(notified, 0, reason: 'must not notify before the first await');

    await future;
    expect(repo.requests, [(42, 1)]);
    expect(vm.state.status, PostRepliesStatus.ready);
    expect(vm.state.replies, replies);
    expect(notified, 1);
  });

  test('a failing repository ends in the failed state', () async {
    Object? logged;
    final vm = PostRepliesViewModel(_StubRepliesRepository(throwError: true), logError: (error, _) => logged = error);

    await vm.load(_FakePost(1));

    expect(vm.state.status, PostRepliesStatus.failed);
    expect(vm.state.replies, isEmpty);
    expect(logged, isNotNull);
  });
}
