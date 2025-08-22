package store

import (
	"apiv2/internal/models"
	"fmt"

	"gorm.io/gorm"
)

type MessageStore struct {
	db *gorm.DB
}

func NewMessageStore(db *gorm.DB) *MessageStore {
	return &MessageStore{
		db: db,
	}
}
func (ms MessageStore) Create(m *models.Message) error {
	err := ms.db.Create(m).Error
	if err != nil {
		return fmt.Errorf("error creating message: %s", err.Error())
	}

	return nil
}
