package handlers

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
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
	return nil
}
