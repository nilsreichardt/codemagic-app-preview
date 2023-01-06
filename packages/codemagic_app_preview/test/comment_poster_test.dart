import 'package:codemagic_app_preview/src/comment/comment_poster.dart';
import 'package:codemagic_app_preview/src/comment/posted_comment.dart';
import 'package:codemagic_app_preview/src/git/github_api_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockGitHubApiRepository extends Mock implements GitHubApiRepository {}

void main() {
  group('CommentPoster', () {
    late CommentPoster poster;
    late MockGitHubApiRepository gitHubApi;

    setUp(() {
      gitHubApi = MockGitHubApiRepository();
      poster = CommentPoster(gitHubApi);
    });

    test('edits the app preview comment when there is already an comment',
        () async {
      when(() => gitHubApi.getComments('1')).thenAnswer(
        (_) async => [
          PostedComment(
            id: 123,
            body: 'random text <!-- Codemagic App Preview; jobId: default -->',
          ),
        ],
      );
      when(() => gitHubApi.editComment(123, 'comment'))
          .thenAnswer((_) async {});

      await poster.post(
        comment: 'comment',
        pullRequestId: '1',
      );

      verify(() => gitHubApi.editComment(123, 'comment'));
    });

    test('posts a new comment when there is no previous app preview comment',
        () async {
      when(() => gitHubApi.getComments('1')).thenAnswer((_) async => []);
      when(() => gitHubApi.postComment('1', 'comment')).thenAnswer((_) async {
        return PostedComment(id: 123, body: 'comment');
      });

      await poster.post(
        comment: 'comment',
        pullRequestId: '1',
      );

      verify(() => gitHubApi.postComment('1', 'comment'));
    });
  });
}
