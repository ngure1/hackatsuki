package store

import (
	"apiv2/internal/models"
	"gorm.io/gorm"
)

type UserStore struct {
	db *gorm.DB
}

// Create implements user.Store.
func (u UserStore) Create(models.User) error {
	panic("unimplemented")
}

// GetUserByEmail implements user.Store.
func (u UserStore) GetUserByEmail(string) (models.User, error) {
	panic("unimplemented")
}

func NewUserStore(db *gorm.DB) *UserStore {
	return &UserStore{
		db: db,
	}
}
