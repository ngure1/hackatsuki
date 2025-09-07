package chat

import "apiv2/internal/models"

type Store interface {
	Create(*models.Chat) (uint, error)
	GetChatById(uint) error
	// limit and offset
	GetChatMessages(uint) ([]models.Message, error)
	GetChats(int, int, uint) ([]models.Chat, int, error)
}
