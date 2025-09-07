package handlers

import (
	"apiv2/internal/models"

	"github.com/gofiber/fiber/v2"
)

const chatsPerPage = 10

func (h *Handler) CreateChat(c *fiber.Ctx) error {
	userId, ok := c.Locals("userId").(uint)
	var chat models.Chat
	if ok {
		chat = models.Chat{
			UserID: &userId,
		}
	}

	chatId, err := h.chatStore.Create(&chat)
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
	userId, _ := c.Locals("userId").(uint)
	page := c.QueryInt("page", 1)
	chats, totalPages, err := h.chatStore.GetChats(page, chatsPerPage, userId)

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error retrieveing chats",
			"error":   err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"chats":       chats,
		"total_pages": totalPages,
	})
}
