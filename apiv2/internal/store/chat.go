package store

import (
	"apiv2/internal/models"
	"apiv2/utils"
	"errors"
	"fmt"
	"math"

	"gorm.io/gorm"
)

type ChatStore struct {
	db *gorm.DB
}

// GetChatWithMessages implements chat.Store.
func (cs *ChatStore) GetChatWithMessages(chatId uint, userId uint) (*models.Chat, error) {
	var chat models.Chat
	err := cs.db.Where("id = ?", chatId).Preload("Messages").First(&chat).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}

	if err != nil {
		return nil, fmt.Errorf("unexpected error when getting chat by id: %s", err.Error())
	}

	if *chat.UserID != userId && !chat.IsPublic {
		return nil, fmt.Errorf("could not access a chat that you did not create")
	}

	return &chat, nil
}

// ShareChat implements chat.Store.
func (cs *ChatStore) ShareChat(chatId uint) error {
	chat, err := cs.GetChatById(chatId)

	if err != nil {
		return err
	}
	chat.IsPublic = true

	return cs.db.Save(chat).Error
}

// SetChatTitle implements chat.Store.
func (cs *ChatStore) SetChatTitle(title string, chatId uint) error {
	var chat models.Chat
	err := cs.db.Where("id = ?", chatId).First(&chat).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("chat not found: %s", err.Error())
	}

	if err != nil {
		return fmt.Errorf("unexpected error when getting chat by id: %s", err.Error())
	}

	chat.Title = title

	return cs.db.Save(chat).Error
}

// GetChats implements chat.Store.
func (cs ChatStore) GetChats(page int, limit int, userId uint) ([]models.Chat, int, error) {
	var chats []models.Chat
	var totalCount int64

	if err := cs.db.Model(&models.Chat{}).Where("user_id = ?", userId).Count(&totalCount).Error; err != nil {
		return nil, 0, fmt.Errorf("error counting chats: %s", err)
	}

	offset := utils.GetOffset(page, limit)
	err := cs.db.Limit(limit).Offset(offset).Where("user_id = ? ", userId).Find(&chats).Error
	if err != nil {
		return nil, 0, fmt.Errorf("error fetching chats: %s", err)
	}

	totalPages := int(math.Ceil(float64(totalCount) / float64(limit)))

	return chats, totalPages, nil
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
func (cs ChatStore) GetChatById(id uint) (*models.Chat, error) {
	var chat models.Chat
	err := cs.db.Where("id = ?", id).First(&chat).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, fmt.Errorf("chat not found: %s", err.Error())
	}

	if err != nil {
		return nil, fmt.Errorf("unexpected error when getting chat by id: %s", err.Error())
	}

	return &chat, nil
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
