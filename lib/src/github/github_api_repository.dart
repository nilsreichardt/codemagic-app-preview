import 'package:http/http.dart';
import 'package:http/testing.dart';

class GitHubApiRepository {
  const GitHubApiRepository({
    required this.token,
    required this.httpClient,
    required this.owner,
    required this.repository,
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

  /// Post a comment
  Future<void> postComment(String pullRequestId, String comment) async {
    final response = await httpClient.post(
      Uri.parse(
        'https://api.github.com/repos/$owner/$repository/issues/$pullRequestId/comments',
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
}
