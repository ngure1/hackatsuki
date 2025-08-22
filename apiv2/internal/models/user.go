package models

import "gorm.io/gorm"

// User
// id (PK)
// name (firstname and last name)
// email (unique, nullable if phone used)
// phone_number (unique, nullable if email used)
// password_hash
// created_at
// updated_at
// role_id (FK → Role.role_id)

type User struct {
	gorm.Model
	FirstName    string  `json:"first_name"`
	LastName     string  `json:"last_name"`
	Email        *string `json:"email"        gorm:"unique;index"`
	PhoneNumber  *string `json:"phone_number" gorm:"unique;index"`
	PasswordHash string  `json:"-"`

	// relations
	Chats []Chat `json:"chats"`
}
