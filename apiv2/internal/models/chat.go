package models

import "gorm.io/gorm"

type Chat struct {
	gorm.Model
	Title string `json:"title" gorm:"index;default:anonymous"`

	// foreign key relations
	UserID   *uint     `json:"user_id,omitempty" gorm:"index"`
	Messages []Message `json:"messages"`
}
