package posts

import "apiv2/internal/models"

type Store interface {
	// limit offset
	GetPosts(int int) ([]models.Post, error)
	GetPost(uint) (models.Post, error)
}
