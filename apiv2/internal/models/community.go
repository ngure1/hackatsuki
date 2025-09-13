package models

import "gorm.io/gorm"

// todo: make all assosiacions like comments likes replies etc ..json empty
// post
type Post struct {
	gorm.Model

	Question    string  `json:"question"`
	Description string  `json:"description"`
	Crop        *string `json:"crop,omitempty"`
	ImageUrl    *string `json:"image_url"`

	UserID   uint      `json:"user_id" gorm:"index"`
	Comments []Comment `json:"-"`
	Likes    []Like    `json:"-"`
}

// comments
type Comment struct {
	gorm.Model
	Content string `json:"content"`

	ParentCommentId *uint     `json:"parent_comment_id"`
	PostId          uint      `json:"post_id"           gorm:"index"`
	UserID          uint      `json:"user_id"`
	Replies         []Comment `json:"-"                 gorm:"foreignkey:ParentCommentId"`
}

// like
type Like struct {
	PostId uint `json:"post_id" gorm:"primaryKey;autoIncrement:false"`
	UserID uint `json:"user_id" gorm:"primaryKey;autoIncrement:false"`
}
