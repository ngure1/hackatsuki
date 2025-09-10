package store

import (
	"apiv2/internal/models"
	"apiv2/utils"
	"errors"
	"fmt"

	"gorm.io/gorm"
)

type PostStore struct {
	db *gorm.DB
}

// GetPost implements posts.Store.
func (ps *PostStore) GetPost(postId uint) (*models.Post, error) {
	var post models.Post
	err := ps.db.Where("id = ?", postId).First(&post).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}
	if err != nil {
		return nil, fmt.Errorf("an unexpected error occured when retrieving post: %s", err.Error())
	}

	return &post, nil
}

// GetPosts implements posts.Store.
func (ps *PostStore) GetPosts(page int, limit int) ([]models.Post, int, error) {
	var posts []models.Post
	var totalCount int64

	if err := ps.db.Model(&models.Post{}).Count(&totalCount).Error; err != nil {
		return nil, 0, fmt.Errorf("error counting posts: %s", err)
	}

	offset := utils.GetOffset(page, limit)
	err := ps.db.Limit(limit).Offset(offset).Find(&posts).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, 0, err
	}

	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when retrieving paginated posts: %s", err.Error())
	}

	return posts, int(totalCount), nil
}

func NewPostStore(db *gorm.DB) *PostStore {
	return &PostStore{
		db: db,
	}
}
