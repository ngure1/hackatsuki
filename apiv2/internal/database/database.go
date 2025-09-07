package database

import (
	"apiv2/internal/models"
	"log"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func New() *gorm.DB {
	db, err := gorm.Open(sqlite.Open("gorm.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("error openning db", err)
	}

	// db.Migrator().DropTable(&models.User{})
	db.AutoMigrate(&models.User{}, &models.Chat{}, &models.Message{})
	return db
}
