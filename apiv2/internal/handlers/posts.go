package handlers

import (
	"errors"
	"fmt"
	"os"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

func (h *Handler) GetPosts(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	posts, totalPages, err := h.postsStore.GetPosts(page, postsPerPage)

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error retrieveing posts",
			"error":   err.Error(),
		})
	}

	// todo add likes count and comment counts and is liked by the current user per post
	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"posts":       posts,
		"total_pages": totalPages,
	})
}

func (h *Handler) GetPost(c *fiber.Ctx) error {
	postIdStr := c.Params("postId")
	postId, err := strconv.ParseUint(postIdStr, 10, 32)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error parsing post id string",
			"error":   err.Error(),
		})
	}

	post, err := h.postsStore.GetPost(uint(postId))
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return c.Status(fiber.StatusNotFound).JSON(&fiber.Map{
			"message": "post with that id does not exist",
			"error":   err.Error(),
		})
	}

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error retrieving post by id",
			"error":   err.Error(),
		})
	}
	return c.Status(fiber.StatusOK).JSON(post)
}

func (h *Handler) CreatePost(c *fiber.Ctx) error {
	userId := c.Locals("userId").(uint)

	file, _ := c.FormFile("image")
	var imageUrl *string = nil
	if file != nil {
		c.SaveFile(file, fmt.Sprintf("%s%s", FilePath, file.Filename))
		urlString := fmt.Sprintf("%s:%s/public/%s", os.Getenv("BACKEND_URL"), os.Getenv("PORT"), file.Filename)
		imageUrl = &urlString
	}

	question := c.FormValue("question")
	description := c.FormValue("description")
	crop := c.FormValue("crop")

	if question == "" || description == "" {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Question or description cannot be empty",
			"error":   "Bad request received empty question or description",
		})
	}

	post, err := h.postsStore.CreatePost(question, description, userId, &crop, imageUrl)

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Failed to create your post",
			"error":   err.Error(),
		})
	}
	return c.Status(fiber.StatusCreated).JSON(post)
}

func (h *Handler) LikePost(c *fiber.Ctx) error {
	userId := c.Locals("userId").(uint)
	postId, _ := c.ParamsInt("postId")

	err := h.postsStore.LikePost(uint(postId), userId)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Failed to like post",
			"error":   err.Error(),
		})
	}
	return c.SendStatus(fiber.StatusOK)
}
