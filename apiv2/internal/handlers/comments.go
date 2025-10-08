package handlers

import (
	"apiv2/requests"
	"errors"
	"strings"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

// CommentOnPost godoc
// @Summary Add a comment to a post
// @Description Creates a comment on a specific post. Supports replying to another comment if `parent_comment_id` is provided.
// @Tags Comments
// @Accept json
// @Produce json
// @Param postId path int true "Post ID"
// @Param comment body requests.CreateCommentRequest true "Comment request body"
// @Success 201 {object} responses.CommentsReponse
// @Failure 400 {object} map[string]string "Invalid request"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /posts/{postId}/comments [post]
func (h *Handler) CommentOnPost(c *fiber.Ctx) error {
	postId, _ := c.ParamsInt("postId")
	userId := c.Locals("userId").(uint)
	body := new(requests.CreateCommentRequest)
	if err := c.BodyParser(body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Something went wrong",
			"error":   "error decoding your json" + err.Error(),
		})
	}

	if strings.Trim(body.Content, " ") == "" {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Comment cannot be empty",
			"error":   "received emtpy comment body",
		})
	}

	comment, err := h.postsStore.CreateComment(body.Content, uint(postId), uint(userId), body.ParentCommentId)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error creating your comment",
			"error":   err.Error(),
		})
	}
	return c.Status(fiber.StatusCreated).JSON(comment)
}

// GetComments godoc
// @Summary Get comments on a post
// @Description Fetch paginated comments for a given post
// @Tags Comments
// @Accept json
// @Produce json
// @Param postId path int true "Post ID"
// @Param page query int false "Page number (default 1)"
// @Success 200 {object} map[string]interface{} "comments: []responses.CommentsReponse, totalPages: int"
// @Failure 400 {object} map[string]string "Invalid post ID"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /posts/{postId}/comments [get]
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

	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"comments":    comments,
		"total_pages": totalPages / commentsPerPage,
	})
}

// GetCommentReplies godoc
// @Summary Get replies to a comment
// @Description Fetch paginated replies for a given comment
// @Tags Comments
// @Accept json
// @Produce json
// @Param commentId path int true "Comment ID"
// @Param page query int false "Page number (default 1)"
// @Success 200 {object} map[string]interface{} "replies: []responses.CommentsReponse, totalPages: int"
// @Failure 400 {object} map[string]string "Invalid comment ID"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /comments/{commentId}/replies [get]
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
		"replies":     replies,
		"total_pages": totalPages / repliesPerPage,
	})
}
