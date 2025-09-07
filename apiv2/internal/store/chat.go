package store

import (
	"apiv2/internal/models"
	"errors"
	"fmt"

	"gorm.io/gorm"
)

type ChatStore struct {
	db *gorm.DB
}

func NewChatStore(db *gorm.DB) *ChatStore {
	return &ChatStore{
		db: db,
	}
}

func (cs ChatStore) Create(c *models.Chat) (uint, error) {
	if err := cs.db.Create(c).Error; err != nil {
		return 0, fmt.Errorf("error creating chat: %s", err)
	}
	return c.ID, nil
}

// GetChatById implements chat.Store.
func (cs ChatStore) GetChatById(id uint) error {
	var chat models.Chat
	err := cs.db.Where("id = ?", id).First(&chat).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("chat not found: %s", err.Error())
	}

	if err != nil {
		return fmt.Errorf("unexpected error when getting chat by id: %s", err.Error())
	}

	return nil
}

// GetChatMessages implements chat.Store.
func (cs ChatStore) GetChatMessages(chatId uint) ([]models.Message, error) {
	var messages []models.Message
	err := cs.db.Where("chat_id = ?", chatId).Find(&messages).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}

	if err != nil {
		return nil, fmt.Errorf("unexpected error when getting chat messages: %s", err.Error())
	}

	return messages, nil
}
