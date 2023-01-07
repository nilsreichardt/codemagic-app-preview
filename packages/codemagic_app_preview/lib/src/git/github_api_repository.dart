import 'dart:convert';

import 'package:codemagic_app_preview/src/comment/posted_comment.dart';
import 'package:codemagic_app_preview/src/git/git_provider_repository.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

class GitHubApiRepository implements GitProviderRepository {
  const GitHubApiRepository({
    required this.token,
    required this.httpClient,
    required this.owner,
    required this.repository,
    required this.pullRequestId,
  });

  /// The client for http requests.
  ///
  /// When testing, use [MockClient] instead.
  final Client httpClient;

  /// The token to use for authentication.
  ///
  /// Typically this is a personal access token.
  final String token;

  /// The owner of the GitHub repository.
  ///
  /// This is usually an user or an organization.
  final String owner;

  /// The name of the GitHub repository.
  final String repository;

  /// The ID of the pull request.
  final String pullRequestId;

  /// Post a new comment.
  @override
  Future<PostedComment> postComment(
    String comment,
  ) async {
    final response = await httpClient.post(
      Uri.parse(
        'https://api.github.com/repos/$owner/$repository/issues/$pullRequestId/comments',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'body': comment,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
          'Failed to post comment: ${response.body} (${response.statusCode})');
    }

    return PostedComment.fromJson(jsonDecode(response.body));
  }

  /// Edits an existing comment.
  @override
  Future<void> editComment(int commentId, String comment) async {
    final response = await httpClient.patch(
      Uri.parse(
        'https://api.github.com/repos/$owner/$repository/issues/comments/$commentId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'body': comment,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to post comment: ${response.body} (${response.statusCode})');
    }
  }

  /// Get all comments for a pull request.
  @override
  Future<List<PostedComment>> getComments() async {
    final response = await httpClient.get(
      Uri.parse(
        'https://api.github.com/repos/$owner/$repository/issues/$pullRequestId/comments',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get comments: ${response.body} (${response.statusCode})');
    }

    return List.from(
      (jsonDecode(response.body)).map((json) => PostedComment.fromJson(json)),
    );
  }
}
