package handlers

import (
	"apiv2/chat"
	"apiv2/messages"
	"apiv2/posts"
	"apiv2/user"
)

const (
	postsPerPage    = 6
	chatsPerPage    = 10
	commentsPerPage = 4
	repliesPerPage  = 3
)

type Handler struct {
	chatStore     chat.Store
	messagesStore messages.Store
	userStore     user.Store
	postsStore    posts.Store
}

func New(cs chat.Store, ms messages.Store, us user.Store, ps posts.Store) *Handler {
	return &Handler{
		chatStore:     cs,
		messagesStore: ms,
		userStore:     us,
		postsStore:    ps,
	}
}
