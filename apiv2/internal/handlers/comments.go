package handlers

import (
	"errors"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
	"gorm.io/gorm"
)

func (h *Handler) CommentOnPost(c *fiber.Ctx) error {
	// todo: confirm this error handling
	postId, _ := c.ParamsInt("postId")
	userId := c.Locals("userId").(uint)
	body := new(CreateCommentRequest)
	if err := c.BodyParser(body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Something went wrong",
			"error":   "error decoding your json" + err.Error(),
		})
	}

	log.Info(body)

	comment, err := h.postsStore.CreateComment(body.Content, uint(postId), uint(userId), body.ParentCommentId)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error creating your comment",
			"error":   err.Error(),
		})
	}
	return c.Status(fiber.StatusCreated).JSON(comment)
}

func (h *Handler) GetComments(c *fiber.Ctx) error {
	postId, _ := c.ParamsInt("postId")
	page := c.QueryInt("page", 1)
	comments, totalPages, err := h.postsStore.GetComments(uint(postId), page, commentsPerPage)
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "invalid post id",
			"error":   err.Error(),
		})
	}
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "an unexpected error occured",
			"error":   err.Error(),
		})
	}

	// todo : add replies count
	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"comments":   comments,
		"totalPages": totalPages,
	})
}

func (h *Handler) GetCommentReplies(c *fiber.Ctx) error {
	commentId, _ := c.ParamsInt("commentId")
	page := c.QueryInt("page", 1)
	replies, totalPages, err := h.postsStore.GetCommentReplies(uint(commentId), page, repliesPerPage)
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "invalid comment id",
			"error":   err.Error(),
		})
	}
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "an unexpected error occured",
			"error":   err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"replies":    replies,
		"totalPages": totalPages,
	})
}
