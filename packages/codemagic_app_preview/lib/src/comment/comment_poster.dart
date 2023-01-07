import 'package:codemagic_app_preview/src/comment/posted_comment.dart';
import 'package:codemagic_app_preview/src/git/git_provider_repository.dart';

class CommentPoster {
  const CommentPoster(this._gitHubApi);

  /// The API of the Git provider (like GitHub) repository.
  final GitProviderRepository _gitHubApi;

  /// Posts a new comment or edits an existing comment.
  Future<void> post({
    required String comment,
    required String pullRequestId,
    String? jobId,
  }) async {
    final comments = await _gitHubApi.getComments(pullRequestId);

    // When no job id is provided, 'default' is used as fallback.
    final previousComment = _getAppPreviewComment(comments, jobId ?? 'default');
    final shouldEdit = previousComment != null;

    if (shouldEdit) {
      await _gitHubApi.editComment(previousComment!.id, comment);
    } else {
      await _gitHubApi.postComment(pullRequestId, comment);
    }
  }

  /// Returns the app preview comment of previous builds if exists.
  ///
  /// Returns null, if there is no app preview comment yet.
  PostedComment? _getAppPreviewComment(
    List<PostedComment> comments,
    String jobId,
  ) {
    for (final comment in comments) {
      if (comment.body
          .contains('<!-- Codemagic App Preview; jobId: $jobId -->')) {
        return comment;
      }
    }

    return null;
  }
}
