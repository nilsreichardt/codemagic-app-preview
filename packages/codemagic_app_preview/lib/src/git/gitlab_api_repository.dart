import 'dart:convert';

import 'package:codemagic_app_preview/src/comment/posted_comment.dart';
import 'package:codemagic_app_preview/src/git/git_host_repository.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

class GitLabApiRepository implements GitHostRepository {
  const GitLabApiRepository({
    required this.token,
    required this.httpClient,
    required this.projectId,
    required this.mergeRequestId,
  });

  /// The client for http requests.
  ///
  /// When testing, use [MockClient] instead.
  final Client httpClient;

  /// The token to use for authentication.
  ///
  /// Typically this is a personal access token.
  final String token;

  /// The ID of the project.
  ///
  /// Can be found in the settings of the project.
  final int projectId;

  /// The ID of the merge request.
  final String mergeRequestId;

  static const String _baseUrl = 'https://gitlab.com';

  /// Post a new comment.
  @override
  Future<PostedComment> postComment(
    String comment,
  ) async {
    final encodedComment = Uri.encodeComponent(comment);
    final response = await httpClient.post(
      Uri.parse(
        '$_baseUrl/api/v4/projects/$projectId/merge_requests/$mergeRequestId/notes?body=$encodedComment',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
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
    final response = await httpClient.put(
      Uri.parse(
        '$_baseUrl/api/v4/projects/$projectId/merge_requests/$mergeRequestId/notes/$commentId?body=$comment',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
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
        '$_baseUrl/api/v4/projects/$projectId/merge_requests/$mergeRequestId/notes/',
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

  static Future<int> getProjectId({
    required String owner,
    required String repoName,
    required String gitLabToken,
    required Client httpClient,
  }) async {
    final response = await httpClient.get(
      Uri.parse(
        'https://gitlab.com/api/v4/projects/$owner%2F$repoName',
      ),
      headers: {
        'Authorization': 'Bearer $gitLabToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get project id: ${response.body} (${response.statusCode})');
    }

    return jsonDecode(response.body)['id'];
  }
}
