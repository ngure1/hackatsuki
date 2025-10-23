package handlers

import (
	"apiv2/internal/models"
	"fmt"
	"os"

	"github.com/gofiber/fiber/v2"
)

// CreateChat godoc
// @Summary Create a new chat
// @Description Creates a new chat associated with the authenticated user
// @Tags Chats
// @Produce json
// @Success 201 {object} map[string]interface{} "chat_id: int, message: string"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /chats [post]
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

// GetChats godoc
// @Summary List user's chats
// @Description Retrieves a paginated list of chats belonging to the authenticated user
// @Tags Chats
// @Produce json
// @Param page query int false "Page number" default(1)
// @Success 200 {object} map[string]interface{} "chats: []responses.ChatMessagesResponse, total_pages: int"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /chats [get]
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

// GetChatMessages godoc
// @Summary Get chat with messages
// @Description Retrieve a single chat and all its messages if the user has permission
// @Tags Chats
// @Produce json
// @Param chatId path int true "Chat ID"
// @Success 200 {object} responses.ChatMessagesResponse
// @Failure 403 {object} map[string]string "Forbidden: cannot access this chat"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /chats/{chatId}/messages [get]
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

// ShareChatToCommunity godoc
// @Summary Share a chat to the community
// @Description Marks a chat as public and creates a post linking to the shared chat
// @Tags Chats
// @Produce json
// @Param chatId path int true "Chat ID"
// @Param question formData string false "Post question/title"
// @Param description formData string false "Post description"
// @Param crop formData string false "Crop or category name"
// @Param image formData file false "Image to attach to post"
// @Success 201 {object} map[string]interface{} "Created post with chat link"
// @Failure 400 {object} map[string]string "Bad request"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /chats/{chatId}/share [post]
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
