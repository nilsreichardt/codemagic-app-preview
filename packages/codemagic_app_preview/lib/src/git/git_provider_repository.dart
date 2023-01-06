import 'package:codemagic_app_preview/src/comment/posted_comment.dart';

abstract class GitProviderRepository {
  /// Post a new comment.
  Future<PostedComment> postComment(String pullRequestId, String comment);

  /// Edits an existing comment.
  Future<void> editComment(int commentId, String comment);

  /// Get all comments for a pull request.
  Future<List<PostedComment>> getComments(String pullRequestId);
}
