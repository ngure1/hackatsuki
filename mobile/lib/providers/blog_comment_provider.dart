// providers/blog_comment_provider.dart

import 'package:flutter/foundation.dart';
import 'package:mobile/data/models/blog_comment.dart';
import 'package:mobile/data/services/blog_service.dart';

class BlogCommentProvider with ChangeNotifier {
  final BlogService _blogService;
  final Map<String, List<BlogComment>> _blogComments = {};
  String? _error;
  bool _isLoading = false;

  BlogCommentProvider(this._blogService);

  String? get error => _error;
  bool get isLoading => _isLoading;

  List<BlogComment> getBlogComments(String blogId) {
    return _blogComments[blogId] ?? [];
  }

  Future<void> loadBlogComments(String blogId, {int page = 1, bool refresh = false}) async {
    if (page == 1 && !refresh && _blogComments.containsKey(blogId)) {
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _blogService.getCommentsForBlog(blogId, page: page);

      if (result['success'] == true) {
        final newComments = result['comments'] as List<BlogComment>;
        
        if (page == 1) {
          _blogComments[blogId] = newComments;
        } else {
          _blogComments[blogId]?.addAll(newComments);
        }
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = 'Failed to load comments: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addComment({
    required String blogId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final result = await _blogService.addBlogComment(
        blogId: blogId,
        content: content,
        parentCommentId: parentCommentId,
      );

      if (result['success'] == true) {
        final newComment = result['comment'] as BlogComment;
        
        if (parentCommentId != null) {
          // If it's a reply, find the parent and add the reply to its list
          _addReplyToComment(blogId, parentCommentId, newComment);
        } else {
          // If it's a top-level comment, add it to the list
          _blogComments.putIfAbsent(blogId, () => []).insert(0, newComment);
        }
        notifyListeners();
        return {'success': true, 'comment': newComment};
      } else {
        _error = result['error'];
        return {'success': false, 'error': _error};
      }
    } catch (e) {
      _error = 'Failed to add comment: $e';
      return {'success': false, 'error': _error};
    }
  }

  Future<void> loadCommentReplies(String blogId, int parentCommentId, {int page = 1}) async {
    _error = null;
    notifyListeners();
    
    try {
      final result = await _blogService.getCommentRepliesById(parentCommentId.toString(), page: page);

      if (result['success'] == true) {
        final replies = (result['replies'] as List)
            .map((r) => BlogComment.fromJson(r))
            .toList();

        _addRepliesToComment(blogId, parentCommentId, replies);
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = 'Failed to load replies: $e';
    }
    notifyListeners();
  }

  void _addReplyToComment(String blogId, int parentId, BlogComment newReply) {
    if (_blogComments.containsKey(blogId)) {
      final comments = _blogComments[blogId]!;
      BlogComment? findAndUpdate(List<BlogComment> list) {
        final index = list.indexWhere((c) => c.id == parentId);
        if (index != -1) {
          final parent = list[index];
          list[index] = parent.copyWith(
            replies: [newReply, ...parent.replies],
            // Note: repliesCount on the parent might also need updating if API doesn't return the full count
          );
          return list[index];
        }
        for (var comment in list) {
          final updated = findAndUpdate(comment.replies);
          if (updated != null) return updated;
        }
        return null;
      }
      findAndUpdate(comments);
    }
  }

  void _addRepliesToComment(String blogId, int parentId, List<BlogComment> newReplies) {
    if (_blogComments.containsKey(blogId)) {
      final comments = _blogComments[blogId]!;
      
      void findAndUpdate(List<BlogComment> list) {
        final index = list.indexWhere((c) => c.id == parentId);
        if (index != -1) {
          final parent = list[index];
          final existingReplies = parent.replies;
          final updatedReplies = [...existingReplies, ...newReplies]; 
          
          list[index] = parent.copyWith(replies: updatedReplies);
          return;
        }
        for (var comment in list) {
          findAndUpdate(comment.replies);
        }
      }
      findAndUpdate(comments);
    }
  }
}