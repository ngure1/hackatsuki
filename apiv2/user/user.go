package user

import "apiv2/internal/models"

type Store interface {
	Create(models.User) error
	GetUserByEmail(string) (*models.User, error)
}
