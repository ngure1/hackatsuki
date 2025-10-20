package responses

import "time"

type SigninResponse struct {
	AccessToken string `json:"access_token"`
}

type CommentsReponse struct {
	ID              uint      `json:"id"`
	Content         string    `json:"content"`
	ParentCommentId *uint     `json:"parent_comment_id"`
	PostId          uint      `json:"post_id"`
	UserID          uint      `json:"user_id"`
	CreatedAt       time.Time `json:"created_at"`
	RepliesCount    int64     `json:"replies_count"`
}

type UserResponse struct {
	ID        uint   `json:"id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
}

type PostResponse struct {
	ID            uint         `json:"id"`
	Question      string       `json:"question"`
	Description   string       `json:"description"`
	Crop          *string      `json:"crop,omitempty"`
	ImageUrl      *string      `json:"image_url"`
	User          UserResponse `json:"user"`
	CommentsCount int64        `json:"comments_count"`
	LikesCount    int64        `json:"likes_count"`
	IsLiked       bool         `json:"is_liked"`
	CreatedAt     time.Time    `json:"created_at"`
	UpdatedAt     time.Time    `json:"updated_at"`
}

// MessageResponse represents a single message in a chat conversation.
// @Description A message sent in a chat, including sender type and timestamps.
type MessageResponse struct {
	ID         string    `json:"id"          example:"msg_123abc"`
	Content    string    `json:"content"     example:"Hey, how are you?"`
	SenderType string    `json:"sender_type" example:"user"`
	ChatID     uint      `json:"chat_id"     example:"1"`
	CreatedAt  time.Time `json:"created_at"  example:"2025-10-12T14:32:00Z"`
}

// ChatMessagesResponse represents a chat and its associated messages.
// @Description Chat with metadata and list of messages for API responses.
type ChatMessagesResponse struct {
	ID        uint              `json:"id"         example:"1"`
	Title     string            `json:"title"      example:"My Chat"`
	IsPublic  bool              `json:"is_public"  example:"true"`
	User      UserResponse      `json:"user"`
	Messages  []MessageResponse `json:"messages"`
	CreatedAt string            `json:"created_at" example:"2025-10-12T14:32:00Z"`
	UpdatedAt string            `json:"updated_at" example:"2025-10-12T14:45:00Z"`
}

// Blog responses
type BlogCommentsResponse struct {
	ID              uint      `json:"id"`
	Content         string    `json:"content"`
	ParentCommentId *uint     `json:"parent_comment_id"`
	BlogId          uint      `json:"blog_id"`
	UserID          uint      `json:"user_id"`
	CreatedAt       time.Time `json:"created_at"`
	RepliesCount    int64     `json:"replies_count"`
}

type BlogResponse struct {
	ID            uint         `json:"id"`
	Title         string       `json:"title"`
	Content       string       `json:"content"`
	User          UserResponse `json:"user"`
	CommentsCount int64        `json:"comments_count"`
	LikesCount    int64        `json:"likes_count"`
	IsLiked       bool         `json:"is_liked"`
	CreatedAt     time.Time    `json:"created_at"`
	UpdatedAt     time.Time    `json:"updated_at"`
}
