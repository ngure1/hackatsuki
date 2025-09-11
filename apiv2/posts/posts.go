package posts

import "apiv2/internal/models"

type Store interface {
	// page limit
	GetPosts(page int, limit int) ([]models.Post, int, error)
	GetPost(postId uint) (*models.Post, error)

	CreatePost(question string, description string, userId uint, crop *string, imageUrl *string) (*models.Post, error)
	LikePost(postId uint, userId uint) error
	CreateComment(content string, postId uint, userId uint, parentCommentId *uint) (*models.Comment, error)
}
