package store

import (
	"apiv2/internal/models"
	"gorm.io/gorm"
)

type PostStore struct {
	db *gorm.DB
}

// GetPost implements posts.Store.
func (p PostStore) GetPost(uint) (models.Post, error) {
	panic("unimplemented")
}

// GetPosts implements posts.Store.
func (p PostStore) GetPosts(int int) ([]models.Post, error) {
	panic("unimplemented")
}

func NewPostStore(db *gorm.DB) *PostStore {
	return &PostStore{
		db: db,
	}
}
