package handlers

import (
	"apiv2/chat"
	"apiv2/messages"
)

type Handler struct {
	chatStore     chat.Store
	messagesStore messages.Store
}

func New(cs chat.Store, ms messages.Store) *Handler {
	return &Handler{
		chatStore:     cs,
		messagesStore: ms,
	}
}
