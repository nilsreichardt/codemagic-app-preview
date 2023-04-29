import 'package:codemagic_app_preview/src/comment/posted_comment.dart';
import 'package:codemagic_app_preview/src/git/git_provider.dart';
import 'package:codemagic_app_preview/src/git/git_repo.dart';
import 'package:codemagic_app_preview/src/git/github_api_repository.dart';
import 'package:codemagic_app_preview/src/git/gitlab_api_repository.dart';
import 'package:http/http.dart';

/// A repository for a Git provider.
///
/// Git providers are GitHub, GitLab, Bitbucket, etc.
abstract class GitProviderRepository {
  /// Post a new comment.
  Future<PostedComment> postComment(String comment);

  /// Edits an existing comment.
  Future<void> editComment(int commentId, String comment);

  /// Get all comments for a pull request.
  Future<List<PostedComment>> getComments();

  /// Returns the Git provider repository for the current [gitRepo].
  ///
  /// [pullRequestId] is the ID of the pull request for the Git provider. For
  /// GitLab, it is the merge request ID.
  static Future<GitProviderRepository> getGitProviderFrom({
    required GitRepo gitRepo,
    required String pullRequestId,
    required String? gitLabToken,
    required String? gitHubToken,
    required Client httpClient,
  }) async {
    final gitProvider = await gitRepo.getProvider();

    switch (gitProvider) {
      case GitProvider.github:
        if (gitHubToken == null) {
          throw MissingGitProviderTokenException(
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
      case GitProvider.gitlab:
        if (gitLabToken == null) {
          throw MissingGitProviderTokenException(
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

class MissingGitProviderTokenException implements Exception {
  final String message;

  MissingGitProviderTokenException(this.message);

  @override
  String toString() => message;
}
