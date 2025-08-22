package handlers

import (
	"apiv2/internal/models"
	"fmt"
	"strconv"
	"sync"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
)

const FilePath = "./"

func (h *Handler) GetDiagnosis(c *fiber.Ctx) error {
	chatIdStr := c.Params("chatId")
	chatId, err := strconv.ParseUint(chatIdStr, 10, 32)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error parsing chat id string",
			"error":   err.Error(),
		})
	}

	err = h.chatStore.GetChatById(uint(chatId))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error retrieving chat by id",
			"error":   err.Error(),
		})
	}

	file, err := c.FormFile("image")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "image file is required",
			"error":   err.Error(),
		})
	}

	c.SaveFile(file, fmt.Sprintf("%s%s", FilePath, file.Filename))
	prompt := c.FormValue("prompt", "")

	userContent := fmt.Sprintf("Image: %s (size: %d bytes)", file.Filename, len(file.Filename))
	if prompt != "" {
		userContent = fmt.Sprintf("Image: %s (size: %d bytes)\nPrompt: %s",
			file.Filename, len(file.Filename), prompt)
	}

	userMessage := &models.Message{
		Content:    userContent,
		SenderType: models.Users,
		ChatID:     uint(chatId),
	}

	var wg sync.WaitGroup

	wg.Add(1)

	go func() {
		defer wg.Done()
		err = h.messagesStore.Create(userMessage)
		if err != nil {
			log.Errorf("error creating message %s", err.Error())
		}
	}()

	wg.Add(1)
	go func() {
		//make gemini api call here
		defer wg.Done()
		time.Sleep(5 * time.Second)
	}()

	wg.Wait()

	return c.JSON(&fiber.Map{
		"chatId": chatId,
	})
}
