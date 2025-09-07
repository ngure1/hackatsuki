package handlers

import (
	"apiv2/internal/models"

	"github.com/gofiber/fiber/v2"
)

const chatsPerPage = 10

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

func (h *Handler) GetChats(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	chats, totalPages, err := h.chatStore.GetChats(page, chatsPerPage, 1)

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error retrieveing chats",
			"error":   err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"chats":      chats,
		"totalPages": totalPages,
	})
}
