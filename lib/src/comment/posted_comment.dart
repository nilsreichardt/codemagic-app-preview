/// A posted comment from GitHub.
class PostedComment {
  const PostedComment(
    this.id,
    this.body,
  );

  factory PostedComment.fromJson(Map<String, dynamic> json) {
    return PostedComment(
      json['id'],
      json['body'],
    );
  }

  /// The comment id
  final int id;

  /// The contents of the comment.
  final String body;
}
