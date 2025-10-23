import 'package:flutter/material.dart';
import 'package:mobile/data/models/blog.dart';
import 'package:mobile/data/models/blog_comment.dart';
import 'package:mobile/providers/blog_comment_provider.dart';
import 'package:mobile/providers/blog_provider.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/appbar_widget.dart';
import 'package:mobile/views/widgets/blog_card_widget.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';
import 'package:provider/provider.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  String? _expandedBlogId;

  final List<String> categories = [
    'All',
    'Weekly Updates',
    'Plant Care',
    'Diseases',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BlogProvider>().loadBlogs();
    });
  }

  void _handleToggleLike(Blog blog) {
    context.read<BlogProvider>().toggleLikeBlog(blog);
    print('Toggled like for blog: ${blog.id}');
  }

  void _toggleComments(String blogId) {
    final isExpanding = _expandedBlogId != blogId;
    setState(() {
      _expandedBlogId = isExpanding ? blogId : null;
    });

    if (isExpanding) {
      // Assuming loadBlogComments is implemented in BlogCommentProvider
      context.read<BlogCommentProvider>().loadBlogComments(blogId);
    }
  }

  void _handleAddComment(
    String blogId,
    String content,
    int? parentCommentId,
  ) async {
    final commentProvider = context.read<BlogCommentProvider>();
    final blogProvider = context.read<BlogProvider>();
    
    final result = await commentProvider.addComment(
      blogId: blogId,
      content: content,
      parentCommentId: parentCommentId,
    );

    if (result['success'] == true && mounted) {
      blogProvider.updateBlogCommentsCount(blogId, 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add comment: ${result['error'] ?? commentProvider.error}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleLoadReplies(String blogId, int commentId) async {
    final commentProvider = context.read<BlogCommentProvider>();
    await commentProvider.loadCommentReplies(blogId, commentId);
  }

  Widget _buildBlogListContent() {
    return Consumer<BlogProvider>(
      builder: (context, blogProvider, child) {
        if (blogProvider.isLoading && blogProvider.blogs.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.green3),
          );
        }

        if (blogProvider.error != null) {
          return Center(
            child: Text(
              'Error loading blogs: ${blogProvider.error}',
              style: AppTheme.bodyMedium.copyWith(color: Colors.red),
            ),
          );
        }

        if (blogProvider.blogs.isEmpty) {
          return Center(
            child: Text('No blogs published yet.'),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          itemCount: blogProvider.blogs.length +
              (blogProvider.hasMoreBlogs ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == blogProvider.blogs.length) {
              blogProvider.loadBlogs();
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: AppTheme.green3),
                ),
              );
            }

            final blog = blogProvider.blogs[index];
            final commentProvider = context.watch<BlogCommentProvider>();
            final blogComments = commentProvider.getBlogComments(
              blog.id.toString(),
            ).cast<BlogComment>(); 
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: BlogCardWidget.fromBlog(
                blog: blog,
                comments: blogComments,
                onLike: () => _handleToggleLike(blog),
                onComment: () => _toggleComments(blog.id.toString()),
                onAddComment: (content, parentCommentId) =>
                    _handleAddComment(
                      blog.id.toString(),
                      content,
                      parentCommentId,
                    ),
                onLoadReplies: (commentId) =>
                    _handleLoadReplies(blog.id.toString(), commentId),
                showComments: _expandedBlogId == blog.id.toString(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: AppTheme.green4,
        appBar: AppbarWidget(),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomContainerWidget(
                color: AppTheme.green2,
                horizontalPadding: 50.0,
                verticalPadding: 30.0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/plant_leaf.png',
                          height: 30,
                          width: 30,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Plant Care Blog',
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Expert tips, weekly updates, and everything you need to keep your plants thriving',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TabBar(
                isScrollable: true,
                labelStyle: AppTheme.labelLarge,
                labelColor: AppTheme.black,
                unselectedLabelColor: AppTheme.gray3,
                indicatorColor: AppTheme.green3,
                tabs: categories
                    .map((category) => Tab(text: category))
                    .toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: categories.map((category) {
                  if (category == 'All') {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildBlogListContent(),
                    );
                  }
                  return Center(
                    child: Text(
                      'No blogs found in "$category" category.',
                      style: AppTheme.bodyMedium,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}