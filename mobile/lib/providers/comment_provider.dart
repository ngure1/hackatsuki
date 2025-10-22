import 'package:flutter/foundation.dart';
import 'package:mobile/data/models/comment.dart';
import 'package:mobile/data/services/post_service.dart';

class CommentProvider with ChangeNotifier {
  final PostService _postService;

  final Map<String, List<Comment>> _postComments = {};

  String? _error;

  CommentProvider(this._postService);

  String? get error => _error;

  List<Comment> getPostComments(String postId) => _postComments[postId] ?? [];

  Future<void> loadPostComments(String postId) async {
    if (_postComments.containsKey(postId) &&
        _postComments[postId]!.isNotEmpty) {
      return;
    }

    try {
      final result = await _postService.getCommentsForPost(postId);

      if (result['success'] == true) {
        final comments = result['comments'] as List<Comment>;
        _postComments[postId] = comments;
        print('loaded comments: $comments');
        _error = null;
      } else {
        _error = result['error'] as String?;
      }
    } catch (e) {
      _error = 'Failed to load comments: $e';
    }
    notifyListeners();
  }

  Future<void> loadCommentReplies(String postId, int commentId) async {
    try {
      final result = await _postService.getCommentRepliesById(
        commentId.toString(),
      );

      if (result['success'] == true) {
        final newReplies = result['replies'] as List<Comment>;

        final comments = _postComments[postId];
        if (comments == null) return;

        _postComments[postId] = _findAndReplaceComment(
          comments,
          commentId,
          (comment) =>
              comment.copyWith(replies: [...comment.replies, ...newReplies]),
        );

        _error = null;
        notifyListeners();
      } else {
        _error = result['error'] as String?;
      }
    } catch (e) {
      _error = 'Failed to load replies: $e';
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final result = await _postService.addCommentToPost(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      );

      if (result['success'] == true) {
        final newCommentJson = result['comment'] as Map<String, dynamic>;
        final newComment = Comment.fromJson(newCommentJson);

        final comments = _postComments[postId];
        if (comments != null) {
          if (parentCommentId == null) {
            comments.insert(0, newComment);
          } else {
            _postComments[postId] = _findAndReplaceComment(
              comments,
              parentCommentId,
              (comment) =>
                  comment.copyWith(replies: [...comment.replies, newComment]),
            );
          }
        }

        _error = null;
        notifyListeners();
        return {'success': true, 'newComment': newComment};
      } else {
        _error = result['error'] as String?;
        notifyListeners();
        return {'success': false, 'error': _error};
      }
    } catch (e) {
      _error = 'Failed to add comment: $e';
      notifyListeners();
      return {'success': false, 'error': _error};
    }
  }

  List<Comment> _findAndReplaceComment(
    List<Comment> comments,
    int targetId,
    Comment Function(Comment) update,
  ) {
    return comments.map((comment) {
      if (comment.id == targetId) {
        return update(comment);
      }

      if (comment.replies.isNotEmpty) {
        final newReplies = _findAndReplaceComment(
          comment.replies,
          targetId,
          update,
        );
        if (newReplies != comment.replies) {
          return comment.copyWith(replies: newReplies);
        }
      }
      return comment;
    }).toList();
  }
}
