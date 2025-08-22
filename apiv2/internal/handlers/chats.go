package handlers

import (
	"apiv2/internal/models"

	"github.com/gofiber/fiber/v2"
)

func (h *Handler) CreateChat(c *fiber.Ctx) error {
	// todo: implement auth middleware to get the userid from c.locals
	chatId, err := h.chatStore.Create(&models.Chat{})
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error creating chat",
			"error":   err,
		})
	}

	return c.Status(201).JSON(&fiber.Map{
		"chat_id": chatId,
		"message": "chat created succesfully",
	})
}
