package models

import (
	"fmt"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Message
// message_id (PK)
// chat_id (FK → Chat.chat_id)
// sender_type (ENUM: "user" | "model")
// content
// query_filter (nullable → e.g., SQL/JSON structure from model to filter products)
// created_at

type SenderType string

const (
	Users  SenderType = "user"
	Models SenderType = "model"
)

type Message struct {
	Id         string     `json:"id"          gorm:"primaryKey"`
	Content    string     `json:"content"     gorm:"size:10000"`
	SenderType SenderType `json:"sender_type" gorm:"index"`
	CreatedAt  time.Time  `json:"created_at"`

	// relations foreign keys
	ChatID uint `json:"chat_id" gorm:"index"`
}

func (s SenderType) IsValid() bool {
	return s == Users || s == Models
}

func (m *Message) BeforeCreate(tx *gorm.DB) (err error) {
	if !m.SenderType.IsValid() {
		return fmt.Errorf("invalid sender_type: %s", m.SenderType)
	}

	m.Id = uuid.NewString()
	return
}
