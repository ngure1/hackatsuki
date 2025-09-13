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
