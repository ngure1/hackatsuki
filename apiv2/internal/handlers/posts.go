package handlers

import (
	"apiv2/internal/models"
	"errors"
	"fmt"
	"os"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

func (h *Handler) handleCreatePost(c *fiber.Ctx, userId uint, chatUrl *string) (*models.Post, error) {
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
	tags := c.FormValue("tags")
	var tagsPtr *string
	if tags != "" {
		tagsPtr = &tags
	}

	if question == "" || description == "" {
		return nil, fmt.Errorf("question or description cannot be empty")
	}

	post, err := h.postsStore.CreatePost(question, description, userId, &crop, imageUrl, chatUrl, tagsPtr)
	if err != nil {
		return nil, err
	}

	return post, nil
}

// GetPosts godoc
// @Summary List posts
// @Description Retrieve paginated list of posts
// @Tags Posts
// @Produce json
// @Param page query int false "Page number" default(1)
// @Success 200 {object} map[string]interface{} "posts: []responses.PostResponse, total_pages: int"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /posts [get]
func (h *Handler) GetPosts(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	tags := c.Query("tags", "")

	// Get userId from context if available (optional auth)
	var userId *uint = nil
	if userIdValue := c.Locals("userId"); userIdValue != nil {
		userIdUint := userIdValue.(uint)
		userId = &userIdUint
	}

	posts, totalPages, err := h.postsStore.GetPosts(page, postsPerPage, userId, &tags)

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error retrieveing posts",
			"error":   err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"posts":       posts,
		"total_pages": (totalPages / postsPerPage),
	})
}

// GetPost godoc
// @Summary Get a single post
// @Description Retrieve a post by its ID
// @Tags Posts
// @Accept  json
// @Produce  json
// @Param   postId  path  int  true  "Post ID"
// @Success 200 {object} responses.PostResponse
// @Failure 404 {object} map[string]string "Post not found"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /posts/{postId} [get]
func (h *Handler) GetPost(c *fiber.Ctx) error {
	postIdStr := c.Params("postId")
	postId, err := strconv.ParseUint(postIdStr, 10, 32)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error parsing post id string",
			"error":   err.Error(),
		})
	}

	// Get userId from context if available (optional auth)
	var userId *uint = nil
	if userIdValue := c.Locals("userId"); userIdValue != nil {
		userIdUint := userIdValue.(uint)
		userId = &userIdUint
	}

	post, err := h.postsStore.GetPost(uint(postId), userId)
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

// CreatePost godoc
// @Summary Create a post
// @Description Create a new post with question, description, and optional image
// @Tags Posts
// @Accept multipart/form-data
// @Produce json
// @Param question formData string true "Post question"
// @Param description formData string true "Post description"
// @Param crop formData string false "Crop name"
// @Param image formData file false "Image file"
// @Success 201 {object} responses.PostResponse
// @Failure 400 {object} map[string]string "Bad request"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /posts [post]
func (h *Handler) CreatePost(c *fiber.Ctx) error {
	userId := c.Locals("userId").(uint)

	post, err := h.handleCreatePost(c, userId, nil)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Failed to create post",
			"error":   err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(post)
}

// DeletePost godoc
// @Summary Delete a post
// @Tags Posts
// @Produce json
// @Param postId path int true "Post ID"
// @Success 200 {string} string "ok"
// @Failure 500 {object} map[string]string "Failed to Delete post"
// @Router /posts/{postId} [delete]
func (h *Handler) DeletePost(c *fiber.Ctx) error {
	postId, _ := c.ParamsInt("postId")
	userId := c.Locals("userId").(uint)

	err := h.postsStore.DeletePost(uint(postId), userId)

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "invalid post id",
			"error":   err.Error(),
		})
	}

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Failed to delete post",
			"error":   err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"message": "Post deleted successfully",
	})
}

// LikePost godoc
// @Summary Toggle like on a post
// @Description Like or unlike a post by ID (toggles the like status)
// @Tags Posts
// @Produce json
// @Param postId path int true "Post ID"
// @Success 200 {object} map[string]interface{} "liked: bool, message: string"
// @Failure 500 {object} map[string]string "Failed to toggle like on post"
// @Router /posts/{postId}/likes [post]
func (h *Handler) LikePost(c *fiber.Ctx) error {
	userId := c.Locals("userId").(uint)
	postId, _ := c.ParamsInt("postId")

	isLiked, err := h.postsStore.ToggleLikePost(uint(postId), userId)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Failed to toggle like on post",
			"error":   err.Error(),
		})
	}

	message := "Post liked successfully"
	if !isLiked {
		message = "Post unliked successfully"
	}

	return c.Status(fiber.StatusOK).JSON(&fiber.Map{
		"liked":   isLiked,
		"message": message,
	})
}
