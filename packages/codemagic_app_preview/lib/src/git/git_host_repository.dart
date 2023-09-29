import 'package:codemagic_app_preview/src/comment/posted_comment.dart';
import 'package:codemagic_app_preview/src/git/git_host.dart';
import 'package:codemagic_app_preview/src/git/git_repo.dart';
import 'package:codemagic_app_preview/src/git/github_api_repository.dart';
import 'package:codemagic_app_preview/src/git/gitlab_api_repository.dart';
import 'package:http/http.dart';

/// A repository for a Git host.
///
/// Git hosts are GitHub, GitLab, Bitbucket, etc.
abstract class GitHostRepository {
  /// Post a new comment.
  Future<PostedComment> postComment(String comment);

  /// Edits an existing comment.
  Future<void> editComment(int commentId, String comment);

  /// Get all comments for a pull request.
  Future<List<PostedComment>> getComments();

  /// Returns the Git host repository for the current [gitRepo].
  ///
  /// [pullRequestId] is the ID of the pull request for the Git host. For
  /// GitLab, it is the merge request ID.
  static Future<GitHostRepository> getGitHostFrom({
    required GitRepo gitRepo,
    required String pullRequestId,
    required String? gitLabToken,
    required String? gitHubToken,
    required Client httpClient,
  }) async {
    final gitHost = await gitRepo.getHost();

    switch (gitHost) {
      case GitHost.github:
        if (gitHubToken == null) {
          throw MissingGitHostTokenException(
              'The GitHub access token is not set. Please set the token with the --github_token option.');
        }

        final owner = await gitRepo.getOwner();
        final repoName = await gitRepo.getRepoName();

        return GitHubApiRepository(
          token: gitHubToken,
          httpClient: httpClient,
          owner: owner,
          repository: repoName,
          pullRequestId: pullRequestId,
        );
      case GitHost.gitlab:
        if (gitLabToken == null) {
          throw MissingGitHostTokenException(
              'The GitLab access token is not set. Please set the token with the --gitlab_token option.');
        }

        final projectId = await GitLabApiRepository.getProjectId(
          owner: await gitRepo.getOwner(),
          repoName: await gitRepo.getRepoName(),
          gitLabToken: gitLabToken,
          httpClient: httpClient,
        );

        return GitLabApiRepository(
          token: gitLabToken,
          httpClient: httpClient,
          mergeRequestId: pullRequestId,
          projectId: projectId,
        );
    }
  }
}

class MissingGitHostTokenException implements Exception {
  final String message;

  MissingGitHostTokenException(this.message);

  @override
  String toString() => message;
}
