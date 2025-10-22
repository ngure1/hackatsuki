// data/services/blog_service.dart

import 'dart:convert';
import 'package:mobile/data/models/blog.dart';
import 'package:mobile/data/models/blog_comment.dart'; 
import 'package:mobile/data/services/auth/auth_service.dart';
import 'package:mobile/data/utils.dart';

class BlogService {
  final AuthService _authService;

  BlogService(this._authService);

  Future<Map<String, dynamic>> getBlogs({int page = 1}) async {
    try {
      final response = await _authService.get(
        '${ApiEndpoints.getBlogs}?page=$page',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'blogs': (data['blogs'] as List)
              .map((blog) => Blog.fromJson(blog))
              .toList(),
          'nextPage': data['next'] != null ? page + 1 : null,
          'previousPage': data['previous'] != null ? page - 1 : null,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load blogs: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to load blogs: $e'};
    }
  }

  Future<Map<String, dynamic>> toggleLikeBlog(String blogId) async {
    try {
      final response = await _authService.post(
        ApiEndpoints.toggleBlogLike(blogId),
        {}, 
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': 'Failed to toggle like: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to toggle like: $e'};
    }
  }

  Future<Map<String, dynamic>> addBlogComment({
    required String blogId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final Map<String, dynamic> body = {'content': content};

      if (parentCommentId != null) {
        body['parent_comment_id'] = parentCommentId;
      }

      final response = await _authService.post(
        ApiEndpoints.addBlogComment(blogId),
        body,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true, 
          'comment': BlogComment.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to add comment: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to add comment: $e'};
    }
  }

  Future<Map<String, dynamic>> getCommentsForBlog(String blogId, {int page = 1}) async {
    try {
      final response = await _authService.get(
        '${ApiEndpoints.getBlogComments(blogId)}?page=$page',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final comments = (data['results'] as List)
            .map(
              (commentJson) => BlogComment.fromJson(commentJson as Map<String, dynamic>),
            )
            .toList();

        return {
          'success': true,
          'comments': comments,
          'nextPage': data['next'] != null ? page + 1 : null,
          'previousPage': data['previous'] != null ? page - 1 : null,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load comments: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to load comments: $e'};
    }
  }

  Future<Map<String, dynamic>> getCommentRepliesById(String commentId, {int page = 1}) async {
    try {
      final response = await _authService.get(
        '${ApiEndpoints.getBlogCommentReplies(commentId)}?page=$page',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final replies = (data['results'] as List)
            .map((replyJson) => BlogComment.fromJson(replyJson))
            .toList();
            
        return {
          'success': true,
          'replies': replies,
          'nextPage': data['next'] != null ? page + 1 : null,
          'previousPage': data['previous'] != null ? page - 1 : null,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load replies: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to load replies: $e'};
    }
  }
}