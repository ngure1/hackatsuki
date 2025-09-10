package posts

import "apiv2/internal/models"

type Store interface {
	// page limit
	GetPosts(int, int) ([]models.Post, int, error)
	GetPost(uint) (*models.Post, error)

	CreatePost(string, string, uint, *string, *string) (*models.Post, error)
}
