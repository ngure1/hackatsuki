package blogs

import (
	"apiv2/internal/models"
	"apiv2/responses"
)

type Store interface {
	// page limit
	GetBlogs(page int, limit int) ([]responses.BlogResponse, int, error)
	GetBlog(blogId uint) (*responses.BlogResponse, error)
	DeleteBlog(blogId uint, userId uint) error

	CreateBlog(
		title string,
		content string,
		userId uint,
	) (*models.Blog, error)
	LikeBlog(blogId uint, userId uint) error
	CreateBlogComment(content string, blogId uint, userId uint, parentCommentId *uint) (*models.BlogComment, error)
	GetBlogComments(blogId uint, page int, limit int) ([]responses.BlogCommentsResponse, int, error)
	GetBlogCommentReplies(commentId uint, page int, limit int) ([]models.BlogComment, int, error)
}
