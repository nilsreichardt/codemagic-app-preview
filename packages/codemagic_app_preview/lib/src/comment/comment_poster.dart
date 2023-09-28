import 'package:codemagic_app_preview/src/comment/posted_comment.dart';
import 'package:codemagic_app_preview/src/git/git_provider_repository.dart';

class CommentPoster {
  const CommentPoster(this._gitHubApi);

  /// The API of the Git provider (like GitHub) repository.
  final GitProviderRepository _gitHubApi;

  /// Posts a new comment or edits an existing comment.
  Future<void> post({
    required String comment,
    String? appName,
  }) async {
    final comments = await _gitHubApi.getComments();

    // When no job id is provided, 'default' is used as fallback.
    final previousComment =
        _getAppPreviewComment(comments, appName ?? 'default');
    final shouldEdit = previousComment != null;

    if (shouldEdit) {
      await _gitHubApi.editComment(previousComment!.id, comment);
    } else {
      await _gitHubApi.postComment(comment);
    }
  }

  /// Returns the app preview comment of previous builds if exists.
  ///
  /// Returns null, if there is no app preview comment yet.
  PostedComment? _getAppPreviewComment(
    List<PostedComment> comments,
    String appName,
  ) {
    for (final comment in comments) {
      if (comment.body
          .contains('<!-- Codemagic App Preview; appName: $appName -->')) {
        return comment;
      }
    }

    return null;
  }
}
