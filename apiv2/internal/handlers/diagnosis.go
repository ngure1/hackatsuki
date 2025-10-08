package handlers

import (
	"apiv2/internal/models"
	p "apiv2/internal/prompt"
	"bufio"
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

	var previousMessages string
	messages, err := h.chatStore.GetChatMessages(uint(chatId))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error retrieving chat messages",
			"error":   err.Error(),
		})
	}
	for _, message := range messages {
		previousMessages += fmt.Sprintf("{role: %s,content: %s}", message.SenderType, message.Content)
	}
	imageRequired := len(messages) == 0
	file, err := c.FormFile("image")
	if err != nil && imageRequired {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "image file is required",
			"error":   err.Error(),
		})
	}
	var userContent string
	if file != nil {
		c.SaveFile(file, fmt.Sprintf("%s%s", FilePath, file.Filename))
		userContent += fmt.Sprintf("Image: %s (size: %d bytes)\n", file.Filename, len(file.Filename))
	}

	prompt := c.FormValue("prompt", "")
	if prompt != "" {
		userContent += fmt.Sprintf("Prompt: %s", prompt)
	}

	userMessage := &models.Message{
		Content:    userContent,
		SenderType: models.Users,
		ChatID:     uint(chatId),
	}

	var wg sync.WaitGroup

	// create chat title
	if len(messages) == 0 {
		wg.Add(1)
		go func() {
			defer wg.Done()
			ctx := c.UserContext()
			client, _ := genai.NewClient(ctx, &genai.ClientConfig{
				APIKey:  os.Getenv("GEMINI_API_KEY"),
				Backend: genai.BackendGeminiAPI,
			})

			var parts []*genai.Part

			parts = append(
				parts,
				genai.NewPartFromText("You are given the following two text inputs"),
				genai.NewPartFromText(fmt.Sprintf("System Prompt:\n%s", p.SystemPrompt)),
				genai.NewPartFromText(fmt.Sprintf("User Prompt:\n%s", prompt)),
				genai.NewPartFromText(p.TitlePrompt),
			)

			if file != nil {
				uploadedFile, _ := client.Files.UploadFromPath(
					ctx,
					fmt.Sprintf("%s%s", FilePath, file.Filename),
					nil,
				)
				parts = append(parts, genai.NewPartFromURI(uploadedFile.URI, uploadedFile.MIMEType))
			}

			contents := []*genai.Content{
				genai.NewContentFromParts(parts, genai.RoleUser),
			}

			title, genErr := client.Models.GenerateContent(ctx, "gemini-2.5-flash", contents, nil)
			if genErr != nil {
				log.Errorf("error generating title: %s", genErr)
				return
			}

			setErr := h.chatStore.SetChatTitle(title.Text(), uint(chatId))
			if setErr != nil {
				log.Errorf("error setting chat title: %s", setErr)
			}
		}()
	}

	wg.Add(1)
	go func() {
		defer wg.Done()
		err = h.messagesStore.Create(userMessage)
		if err != nil {
			log.Errorf("error creating message %s", err.Error())
		}
	}()

	c.Context().SetBodyStreamWriter(func(w *bufio.Writer) {
		ctx := c.UserContext()

		client, err := genai.NewClient(ctx, &genai.ClientConfig{
			APIKey:  os.Getenv("GEMINI_API_KEY"),
			Backend: genai.BackendGeminiAPI,
		})
		if err != nil {
			fmt.Fprintf(w, "error creating genai client: %s\n", err)
			w.Flush()
			return
		}

		var parts []*genai.Part

		parts = append(parts,
			genai.NewPartFromText(fmt.Sprintf("System Prompt:\n%s", p.SystemPrompt)),
			genai.NewPartFromText(fmt.Sprintf("Chat history:\n%s", previousMessages)),
			genai.NewPartFromText(fmt.Sprintf("User Prompt:\n%s", prompt)),
		)

		if file != nil {
			uploadedFile, _ := client.Files.UploadFromPath(
				ctx,
				fmt.Sprintf("%s%s", FilePath, file.Filename),
				nil,
			)
			parts = append(parts, genai.NewPartFromURI(uploadedFile.URI, uploadedFile.MIMEType))
		}

		contents := []*genai.Content{
			genai.NewContentFromParts(parts, genai.RoleUser),
		}

		// stream chunks
		stream := client.Models.GenerateContentStream(ctx, "gemini-2.5-flash", contents, nil)
		var modelResponse string
		for resp, err := range stream {
			if err != nil {
				fmt.Fprintf(w, "error: %v\n", err)
				w.Flush()
				break
			}
			for _, cand := range resp.Candidates {
				for _, part := range cand.Content.Parts {
					text := part.Text
					fmt.Fprintf(w, "%s", text)
					modelResponse += text
					w.Flush()
				}
			}
		}

		modelMessage := &models.Message{
			ChatID:     uint(chatId),
			SenderType: models.Models,
			Content:    modelResponse,
		}
		h.messagesStore.Create(modelMessage)
	})

	c.Set("Content-Type", "text/plain")
	return c.SendStatus(fiber.StatusOK)
}
