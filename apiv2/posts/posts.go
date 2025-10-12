package posts

import (
	"apiv2/internal/models"
	"apiv2/responses"
)

type Store interface {
	// page limit
	GetPosts(page int, limit int) ([]responses.PostResponse, int, error)
	GetPost(postId uint) (*responses.PostResponse, error)
	DeletePost(postId uint, userId uint) error

	CreatePost(
		question string,
		description string,
		userId uint,
		crop *string,
		imageUrl *string,
		chatUrl *string,
	) (*models.Post, error)
	LikePost(postId uint, userId uint) error
	CreateComment(content string, postId uint, userId uint, parentCommentId *uint) (*models.Comment, error)
	GetComments(postId uint, page int, limit int) ([]responses.CommentsReponse, int, error)
	GetCommentReplies(commentId uint, page int, limit int) ([]models.Comment, int, error)
}
