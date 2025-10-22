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
	ChatUrl     *string `json:"chat_url,omitempty"`

	UserID   uint      `json:"user_id" gorm:"index"`
	User     User      `json:"user"    gorm:"foreignkey:UserID"`
	Comments []Comment `json:"-"`
	Likes    []Like    `json:"-"`
}

// comments
type Comment struct {
	gorm.Model
	Content string `json:"content"`

	ParentCommentId *uint     `json:"parent_comment_id"`
	PostId          uint      `json:"post_id"           gorm:"index"`
	UserID          uint      `json:"user_id"           gorm:"index"`
	User            User      `json:"user"              gorm:"foreignkey:UserID"`
	Replies         []Comment `json:"-"                 gorm:"foreignkey:ParentCommentId"`
}

// like
type Like struct {
	PostId uint `json:"post_id" gorm:"primaryKey;autoIncrement:false"`
	UserID uint `json:"user_id" gorm:"primaryKey;autoIncrement:false"`
}

// Blog
type Blog struct {
	gorm.Model

	Title   string `json:"title"`
	Content string `json:"content"` // HTML content for rich text blogs

	UserID       uint          `json:"user_id" gorm:"index"`
	User         User          `json:"user"    gorm:"foreignkey:UserID"`
	BlogComments []BlogComment `json:"-"`
	BlogLikes    []BlogLike    `json:"-"`
}

// Blog comments
type BlogComment struct {
	gorm.Model
	Content string `json:"content"`

	ParentCommentId *uint         `json:"parent_comment_id"`
	BlogId          uint          `json:"blog_id"           gorm:"index"`
	UserID          uint          `json:"user_id"           gorm:"index"`
	User            User          `json:"user"              gorm:"foreignkey:UserID"`
	Replies         []BlogComment `json:"-"                 gorm:"foreignkey:ParentCommentId"`
}

// Blog like
type BlogLike struct {
	BlogId uint `json:"blog_id" gorm:"primaryKey;autoIncrement:false"`
	UserID uint `json:"user_id" gorm:"primaryKey;autoIncrement:false"`
}
