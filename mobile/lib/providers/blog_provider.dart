// providers/blog_provider.dart

import 'package:flutter/foundation.dart';
import 'package:mobile/data/models/blog.dart';
import 'package:mobile/data/services/blog_service.dart';

class BlogProvider with ChangeNotifier {
  final BlogService _blogService;

  final List<Blog> _blogs = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreBlogs = true;

  BlogProvider(this._blogService);

  List<Blog> get blogs => _blogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreBlogs => _hasMoreBlogs;

  Future<void> loadBlogs({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _currentPage = 1;
      _hasMoreBlogs = true;
      _blogs.clear();
    }

    if (!_hasMoreBlogs) return;

    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      final result = await _blogService.getBlogs(page: _currentPage);
      _isLoading = false;

      if (result['success'] == true) {
        final newBlogs = result['blogs'] as List<Blog>;
        _blogs.addAll(newBlogs);
        _hasMoreBlogs = result['nextPage'] != null;
        _currentPage++;
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load blogs: $e';
    }

    notifyListeners();
  }

  Future<bool> toggleLikeBlog(Blog blog) async {
    final blogId = blog.id.toString();
    final bool currentlyLiked = blog.isLikedByCurrentUser == true;
    final int change = currentlyLiked ? -1 : 1;

    try {
      final result = await _blogService.toggleLikeBlog(blogId);

      if (result['success'] == true) {
        _updateBlogLikes(blogId, change, newIsLiked: !currentlyLiked);
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to toggle like: $e';
      notifyListeners();
      return false;
    }
  }

  void _updateBlogLikes(String blogId, int change, {required bool newIsLiked}) {
    final index = _blogs.indexWhere((blog) => blog.id.toString() == blogId);
    if (index != -1) {
      final blog = _blogs[index];
      _blogs[index] = Blog(
        id: blog.id,
        title: blog.title,
        content: blog.content,
        commentsCount: blog.commentsCount,
        likesCount: (blog.likesCount ?? 0) + change,
        user: blog.user,
        isLikedByCurrentUser: newIsLiked,
      );
      notifyListeners();
    }
  }
  
  void updateBlogCommentsCount(String blogId, int change) {
    final index = _blogs.indexWhere((blog) => blog.id.toString() == blogId);
    if (index != -1) {
      final blog = _blogs[index];
      _blogs[index] = Blog(
        id: blog.id,
        title: blog.title,
        content: blog.content,
        commentsCount: (blog.commentsCount ?? 0) + change,
        likesCount: blog.likesCount,
        user: blog.user,
        isLikedByCurrentUser: blog.isLikedByCurrentUser,
      );
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}