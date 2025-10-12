package handlers

import (
	"apiv2/internal/models"
	"fmt"
	"os"

	"github.com/gofiber/fiber/v2"
)

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
		"total_pages": totalPages / chatsPerPage,
	})
}

func (h *Handler) GetChatMessages(c *fiber.Ctx) error {
	chatId, _ := c.ParamsInt("chatId")
	userId := c.Locals("userId").(uint)
	chat, err := h.chatStore.GetChatWithMessages(uint(chatId), userId)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error retrieveing chat",
			"error":   err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(chat)
}

func (h *Handler) ShareChatToCommunity(c *fiber.Ctx) error {
	chatId, _ := c.ParamsInt("chatId")
	userId := c.Locals("userId").(uint)

	if err := h.chatStore.ShareChat(uint(chatId)); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Unable to mark chat as public",
			"error":   err.Error(),
		})
	}

	chatUrl := fmt.Sprintf("%s:%s/chats/%d", os.Getenv("BACKEND_URL"), os.Getenv("PORT"), chatId)

	post, err := h.handleCreatePost(c, userId, &chatUrl)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Failed to create post from chat share",
			"error":   err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(post)
}
