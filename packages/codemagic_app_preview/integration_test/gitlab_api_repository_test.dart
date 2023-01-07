import 'dart:convert';

import 'package:codemagic_app_preview/src/comment/posted_comment.dart';
import 'package:codemagic_app_preview/src/git/gitlab_api_repository.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  /// Set GITLAB_TOKEN environment variable to run tests.
  ///
  /// Use the following command to use the environment variable:
  /// ```sh
  /// dart --define=GITLAB_TOKEN=... test integration_test --use-data-isolate-strategy
  /// ```
  ///
  /// At the moment, we need to use the `--use-data-isolate-strategy` flag
  /// because of https://github.com/dart-lang/test/issues/1794.
  const gitLabToken = String.fromEnvironment('GITLAB_TOKEN');
  late http.Client httpClient;

  /// The project id of the repository to test against.
  const projectId = 42374510;

  setUpAll(() {
    if (gitLabToken.isEmpty) {
      print("⚠️  GITLAB_TOKEN is not set. Skipping tests. ⚠️");
      throw Exception('GITLAB_TOKEN is not set.');
    }
  });

  setUp(() {
    httpClient = http.Client();
  });

  Future<void> _deleteComment({
    required String mergeRequestId,
    required int commentId,
  }) async {
    final response = await httpClient.delete(
      Uri.parse(
        'https://gitlab.com/api/v4/projects/$projectId/merge_requests/$mergeRequestId/notes/$commentId',
      ),
      headers: {
        'Authorization': 'Bearer $gitLabToken',
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
    test('returns "Hey!" as comment', () async {
      final gitLabApiRepository = GitLabApiRepository(
        token: gitLabToken,
        httpClient: httpClient,
        projectId: projectId,
        mergeRequestId: '2',
      );

      final comments = await gitLabApiRepository.getComments();

      final expectedComment = PostedComment(id: 1230787683, body: 'Hey!');
      expect(
        comments.contains(expectedComment),
        true,
      );
    });
  });

  group('.postComment()', () {
    // Posts a comment to
    // https://github.com/nilsreichardt/codemagic-app-preview/pull/16
    test('should post an comment to a PR', () async {
      const pullRequestId = '3';
      final gitLabApiRepository = GitLabApiRepository(
        token: gitLabToken,
        httpClient: httpClient,
        projectId: projectId,
        mergeRequestId: pullRequestId,
      );
      final randomText = DateTime.now().toIso8601String();

      final comment = await gitLabApiRepository.postComment(
        randomText,
      );
      // Remove the comment after the test to avoid having a pull request with
      // thousands of comments.
      addTearDown(() => _deleteComment(
            mergeRequestId: pullRequestId,
            commentId: comment.id,
          ));

      final allComments = await gitLabApiRepository.getComments();
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
      const pullRequestId = '1';
      final gitLabApiRepository = GitLabApiRepository(
        token: gitLabToken,
        httpClient: httpClient,
        projectId: projectId,
        mergeRequestId: pullRequestId,
      );
      const commentId = 1230789237;
      final randomText = DateTime.now().toIso8601String();

      await gitLabApiRepository.editComment(commentId, randomText);

      final allComments = await gitLabApiRepository.getComments();
      expect(
        allComments.contains(PostedComment(id: commentId, body: randomText)),
        true,
      );
    });
  });
}
