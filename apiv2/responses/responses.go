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
}
