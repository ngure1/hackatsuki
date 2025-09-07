package store

import (
	"apiv2/internal/models"
	"errors"
	"fmt"

	"gorm.io/gorm"
)

type UserStore struct {
	db *gorm.DB
}

// Create implements user.Store.
func (us UserStore) Create(newUser models.User) error {
	err := us.db.Create(&newUser).Error
	if err != nil {
		return fmt.Errorf("error creating user: %w", err)
	}
	return nil
}

// GetUserByEmail implements user.Store.
func (us UserStore) GetUserByEmail(email string) (*models.User, error) {
	var existingUser models.User
	err := us.db.Where("email = ? ", email).First(&existingUser).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}

	if err != nil {
		return nil, fmt.Errorf("an unexpected error occured: %s", err)
	}

	return &existingUser, nil
}

func NewUserStore(db *gorm.DB) *UserStore {
	return &UserStore{
		db: db,
	}
}
