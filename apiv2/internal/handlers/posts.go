package handlers

import (
	"errors"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

const postsPerPage = 6

func (h *Handler) GetPosts(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	posts, totalPages, err := h.postsStore.GetPosts(page, postsPerPage)

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error retrieveing posts",
			"error":   err.Error(),
		})
	}

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
	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"post": post,
	})
}
