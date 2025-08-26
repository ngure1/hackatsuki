package handlers

import (
	"apiv2/internal/models"
	p "apiv2/internal/prompt"
	"fmt"
	"os"
	"strconv"
	"sync"

	"google.golang.org/genai"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
)

const FilePath = "./media/"

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
	var response string
	go func() {
		ctx := c.UserContext()
		client, err := genai.NewClient(ctx, &genai.ClientConfig{
			APIKey:  os.Getenv("GEMINI_API_KEY"),
			Backend: genai.BackendGeminiAPI,
		})
		if err != nil {
			log.Errorf("error creating genai client: %s \n", err)
		}

		uploadedFile, _ := client.Files.UploadFromPath(ctx, fmt.Sprintf("%s%s", FilePath, file.Filename), nil)

		parts := []*genai.Part{
			genai.NewPartFromText(fmt.Sprintf("System Prompt: \n %s", p.SystemPrompt)),
			genai.NewPartFromText(fmt.Sprintf("User Prompt: \n %s", prompt)),
			genai.NewPartFromURI(uploadedFile.URI, uploadedFile.MIMEType),
		}

		contents := []*genai.Content{
			genai.NewContentFromParts(parts, genai.RoleUser),
		}

		result, _ := client.Models.GenerateContent(
			ctx,
			"gemini-2.5-flash",
			contents,
			nil,
		)
		response = result.Text()
		defer wg.Done()
	}()

	wg.Wait()

	return c.JSON(&fiber.Map{
		"response": response,
	})
}
