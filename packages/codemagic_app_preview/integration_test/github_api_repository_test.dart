import 'package:codemagic_app_preview/src/comment/posted_comment.dart';
import 'package:codemagic_app_preview/src/git/github_api_repository.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  /// Set GITHUB_TOKEN environment variable to run tests.
  ///
  /// Use the following command to use the environment variable:
  /// ```sh
  /// dart --define=GITHUB_TOKEN=... test integration_test --use-data-isolate-strategy
  /// ```
  ///
  /// At the moment, we need to use the `--use-data-isolate-strategy` flag
  /// because of https://github.com/dart-lang/test/issues/1794.
  const gitHubToken = String.fromEnvironment('GITHUB_TOKEN');
  late GitHubApiRepository gitHubApiRepository;
  late http.Client httpClient;

  /// The owner of the repository to test against.
  const owner = 'nilsreichardt';

  /// The repository to test against.
  const repository = 'codemagic-app-preview';

  setUpAll(() {
    if (gitHubToken.isEmpty) {
      print("⚠️  GITHUB_TOKEN is not set. Skipping tests. ⚠️");
      throw Exception('GITHUB_TOKEN is not set.');
    }
  });

  setUp(() {
    httpClient = http.Client();
    gitHubApiRepository = GitHubApiRepository(
      token: gitHubToken,
      httpClient: httpClient,
      owner: owner,
      repository: repository,
    );
  });

  Future<void> _deleteComment({
    required String pullRequestId,
    required int commentId,
  }) async {
    final response = await httpClient.delete(
      Uri.parse(
        'https://api.github.com/repos/$owner/$repository/issues/comments/$commentId',
      ),
      headers: {
        'Authorization': 'Bearer $gitHubToken',
      },
    );

    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete comment: ${response.body} (${response.statusCode})');
    }
  }

  group('.getComments()', () {
    // Reading the comments from:
    // https://github.com/nilsreichardt/codemagic-app-preview/pull/1
    test('returns "Hey! 👋" as comment', () async {
      final comments = await gitHubApiRepository.getComments('1');

      expect(
        comments,
        [PostedComment(id: 1374005266, body: 'Hey! 👋 ')],
      );
    });
  });

  group('.postComment()', () {
    // Posts a comment to
    // https://github.com/nilsreichardt/codemagic-app-preview/pull/16
    test('should post an comment to a PR', () async {
      const pullRequestId = '16';
      final randomText = DateTime.now().toIso8601String();

      final comment = await gitHubApiRepository.postComment(
        pullRequestId,
        randomText,
      );
      // Remove the comment after the test to avoid having a pull request with
      // thousands of comments.
      addTearDown(() => _deleteComment(
            pullRequestId: pullRequestId,
            commentId: comment.id,
          ));

      final allComments = await gitHubApiRepository.getComments(pullRequestId);
      expect(
        allComments.contains(comment),
        true,
      );
    });
  });

  group('.editComment()', () {
    // Edits the comment on this pull request:
    // https://github.com/nilsreichardt/codemagic-app-preview/pull/19
    test('should edit an comment on a PR', () async {
      const pullRequestId = '19';
      const commentId = 1374061528;
      final randomText = DateTime.now().toIso8601String();

      await gitHubApiRepository.editComment(commentId, randomText);

      final allComments = await gitHubApiRepository.getComments(pullRequestId);
      expect(
        allComments.contains(PostedComment(id: commentId, body: randomText)),
        true,
      );
    });
  });
}
