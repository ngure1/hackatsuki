package handlers

import (
	"apiv2/requests"
	"errors"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

// GetBlogs godoc
// @Summary List blogs
// @Description Retrieve paginated list of blogs
// @Tags Blogs
// @Produce json
// @Param page query int false "Page number" default(1)
// @Success 200 {object} map[string]interface{} "blogs: []responses.BlogResponse, total_pages: int"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /blogs [get]
func (h *Handler) GetBlogs(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	tags := c.Query("tags", "")

	// Get userId from context if available (optional auth)
	var userId *uint = nil
	if userIdValue := c.Locals("userId"); userIdValue != nil {
		userIdUint := userIdValue.(uint)
		userId = &userIdUint
	}

	blogs, totalPages, err := h.blogsStore.GetBlogs(page, postsPerPage, userId, &tags)

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error retrieving blogs",
			"error":   err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"blogs":       blogs,
		"total_pages": (totalPages / postsPerPage),
	})
}

// GetBlog godoc
// @Summary Get a single blog
// @Description Retrieve a blog by its ID
// @Tags Blogs
// @Accept  json
// @Produce  json
// @Param   blogId  path  int  true  "Blog ID"
// @Success 200 {object} responses.BlogResponse
// @Failure 404 {object} map[string]string "Blog not found"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /blogs/{blogId} [get]
func (h *Handler) GetBlog(c *fiber.Ctx) error {
	blogIdStr := c.Params("blogId")
	blogId, err := strconv.ParseUint(blogIdStr, 10, 32)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error parsing blog id string",
			"error":   err.Error(),
		})
	}

	// Get userId from context if available (optional auth)
	var userId *uint = nil
	if userIdValue := c.Locals("userId"); userIdValue != nil {
		userIdUint := userIdValue.(uint)
		userId = &userIdUint
	}

	blog, err := h.blogsStore.GetBlog(uint(blogId), userId)
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return c.Status(fiber.StatusNotFound).JSON(&fiber.Map{
			"message": "blog with that id does not exist",
			"error":   err.Error(),
		})
	}

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error retrieving blog by id",
			"error":   err.Error(),
		})
	}
	return c.Status(fiber.StatusOK).JSON(blog)
}

// CreateBlog godoc
// @Summary Create a blog
// @Description Create a new blog with title and content
// @Tags Blogs
// @Accept json
// @Produce json
// @Param blog body requests.CreateBlogRequest true "Blog creation request"
// @Success 201 {object} responses.BlogResponse
// @Failure 400 {object} map[string]string "Bad request"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /blogs [post]
func (h *Handler) CreateBlog(c *fiber.Ctx) error {
	userId := c.Locals("userId").(uint)
	body := new(requests.CreateBlogRequest)

	if err := c.BodyParser(body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Something went wrong",
			"error":   "error decoding your json: " + err.Error(),
		})
	}

	if strings.Trim(body.Title, " ") == "" || strings.Trim(body.Content, " ") == "" {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Title and content cannot be empty",
			"error":   "received empty title or content",
		})
	}

	blog, err := h.blogsStore.CreateBlog(body.Title, body.Content, userId, body.Tags)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Failed to create blog",
			"error":   err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(blog)
}

// DeleteBlog godoc
// @Summary Delete a blog
// @Tags Blogs
// @Produce json
// @Param blogId path int true "Blog ID"
// @Success 200 {string} string "ok"
// @Failure 500 {object} map[string]string "Failed to Delete blog"
// @Router /blogs/{blogId} [delete]
func (h *Handler) DeleteBlog(c *fiber.Ctx) error {
	blogId, _ := c.ParamsInt("blogId")
	userId := c.Locals("userId").(uint)

	err := h.blogsStore.DeleteBlog(uint(blogId), userId)

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "invalid blog id",
			"error":   err.Error(),
		})
	}

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Failed to delete blog",
			"error":   err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"message": "Blog deleted successfully",
	})
}

// LikeBlog godoc
// @Summary Toggle like on a blog
// @Description Like or unlike a blog by ID (toggles the like status)
// @Tags Blogs
// @Produce json
// @Param blogId path int true "Blog ID"
// @Success 200 {object} map[string]interface{} "liked: bool, message: string"
// @Failure 500 {object} map[string]string "Failed to toggle like on blog"
// @Router /blogs/{blogId}/likes [post]
func (h *Handler) LikeBlog(c *fiber.Ctx) error {
	userId := c.Locals("userId").(uint)
	blogId, _ := c.ParamsInt("blogId")

	isLiked, err := h.blogsStore.ToggleLikeBlog(uint(blogId), userId)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Failed to toggle like on blog",
			"error":   err.Error(),
		})
	}

	message := "Blog liked successfully"
	if !isLiked {
		message = "Blog unliked successfully"
	}

	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"liked":   isLiked,
		"message": message,
	})
}

// CommentOnBlog godoc
// @Summary Add a comment to a blog
// @Description Creates a comment on a specific blog. Supports replying to another comment if `parent_comment_id` is provided.
// @Tags Blogs
// @Accept json
// @Produce json
// @Param blogId path int true "Blog ID"
// @Param comment body requests.CreateBlogCommentRequest true "Comment request body"
// @Success 201 {object} responses.BlogCommentsResponse
// @Failure 400 {object} map[string]string "Invalid request"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /blogs/{blogId}/comments [post]
func (h *Handler) CommentOnBlog(c *fiber.Ctx) error {
	blogId, _ := c.ParamsInt("blogId")
	userId := c.Locals("userId").(uint)
	body := new(requests.CreateBlogCommentRequest)
	if err := c.BodyParser(body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Something went wrong",
			"error":   "error decoding your json" + err.Error(),
		})
	}

	if strings.Trim(body.Content, " ") == "" {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Comment cannot be empty",
			"error":   "received empty comment body",
		})
	}

	comment, err := h.blogsStore.CreateBlogComment(body.Content, uint(blogId), uint(userId), body.ParentCommentId)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error creating your comment",
			"error":   err.Error(),
		})
	}
	return c.Status(fiber.StatusCreated).JSON(comment)
}

// GetBlogComments godoc
// @Summary Get comments on a blog
// @Description Fetch paginated comments for a given blog
// @Tags Blogs
// @Accept json
// @Produce json
// @Param blogId path int true "Blog ID"
// @Param page query int false "Page number (default 1)"
// @Success 200 {object} map[string]interface{} "comments: []responses.BlogCommentsResponse, totalPages: int"
// @Failure 400 {object} map[string]string "Invalid blog ID"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /blogs/{blogId}/comments [get]
func (h *Handler) GetBlogComments(c *fiber.Ctx) error {
	blogId, _ := c.ParamsInt("blogId")
	page := c.QueryInt("page", 1)
	comments, totalPages, err := h.blogsStore.GetBlogComments(uint(blogId), page, commentsPerPage)
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "invalid blog id",
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

// GetBlogCommentReplies godoc
// @Summary Get replies to a blog comment
// @Description Fetch paginated replies for a given blog comment
// @Tags Blogs
// @Accept json
// @Produce json
// @Param commentId path int true "Comment ID"
// @Param page query int false "Page number (default 1)"
// @Success 200 {object} map[string]interface{} "replies: []responses.BlogCommentsResponse, totalPages: int"
// @Failure 400 {object} map[string]string "Invalid comment ID"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /blog-comments/{commentId}/replies [get]
func (h *Handler) GetBlogCommentReplies(c *fiber.Ctx) error {
	commentId, _ := c.ParamsInt("commentId")
	page := c.QueryInt("page", 1)
	replies, totalPages, err := h.blogsStore.GetBlogCommentReplies(uint(commentId), page, repliesPerPage)
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
