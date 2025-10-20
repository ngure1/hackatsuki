package blogs

import (
	"apiv2/internal/models"
	"apiv2/responses"
)

type Store interface {
	// page limit
	GetBlogs(page int, limit int, userId *uint) ([]responses.BlogResponse, int, error)
	GetBlog(blogId uint, userId *uint) (*responses.BlogResponse, error)
	DeleteBlog(blogId uint, userId uint) error

	CreateBlog(
		title string,
		content string,
		userId uint,
	) (*models.Blog, error)
	ToggleLikeBlog(blogId uint, userId uint) (bool, error) // returns true if liked, false if unliked
	CreateBlogComment(content string, blogId uint, userId uint, parentCommentId *uint) (*models.BlogComment, error)
	GetBlogComments(blogId uint, page int, limit int) ([]responses.BlogCommentsResponse, int, error)
	GetBlogCommentReplies(commentId uint, page int, limit int) ([]models.BlogComment, int, error)
}
