package user

import "apiv2/internal/models"

type Store interface {
	Create(models.User) error
	GetUserByEmail(string) (*models.User, error)
	GetUserById(uint) (*models.User, error)
	UpdatePhoneAndLocation(userId uint, phoneNumber string, city *string) error
}
