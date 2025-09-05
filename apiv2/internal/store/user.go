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

	return fmt.Errorf("error creating user: %s", err)
}

// GetUserByEmail implements user.Store.
func (us UserStore) GetUserByEmail(email string) (*models.User, error) {
	var existingUser models.User
	err := us.db.Find("email = ? ", email).First(&existingUser).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, fmt.Errorf("user with that email not found: %s", err)
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
