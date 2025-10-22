package handlers

import (
	"apiv2/requests"
	"apiv2/responses"

	"github.com/gofiber/fiber/v2"
)

// UpdatePhoneAndLocation godoc
// @Summary Update the users phone number and location
// @Description Updates the logged in users phone number and city for better agricultural context
// @Tags Users
// @Accept  json
// @Produce  json
// @Param phoneAndLocation body requests.UpdatePhoneAndLocationRequest true "Phone number and city information"
// @Success 200
// @Failure 401 {object} map[string]string "Unauthenticated
// @Failure 404 {object} map[string]string "User not found"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /users [patch]
func (h *Handler) UpdatePhoneAndLocation(c *fiber.Ctx) error {
	userId := c.Locals("userId").(uint)

	body := new(requests.UpdatePhoneAndLocationRequest)

	if err := c.BodyParser(body); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error decoding body",
			"error":   err.Error(),
		})
	}

	if body.PhoneNumber == "" {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Phone number cannot be empty",
			"error":   "Validation failed",
		})
	}

	err := h.userStore.UpdatePhoneAndLocation(userId, body.PhoneNumber, body.City)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error updating phone number and location",
			"error":   err.Error(),
		})
	}

	return c.SendStatus(fiber.StatusOK)
}

// GetMe godoc
// @Summary Get current user profile
// @Description Get the authenticated user's profile information
// @Tags Users
// @Produce json
// @Success 200 {object} responses.UserProfileResponse
// @Failure 401 {object} map[string]string "Unauthenticated"
// @Failure 404 {object} map[string]string "User not found"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /users/me [get]
func (h *Handler) GetMe(c *fiber.Ctx) error {
	userId := c.Locals("userId").(uint)

	user, err := h.userStore.GetUserById(userId)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error retrieving user profile",
			"error":   err.Error(),
		})
	}

	profileResponse := responses.UserProfileResponse{
		ID:          user.ID,
		FirstName:   user.FirstName,
		LastName:    user.LastName,
		Email:       user.Email,
		PhoneNumber: user.PhoneNumber,
		City:        user.City,
		CreatedAt:   user.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}

	return c.Status(fiber.StatusOK).JSON(profileResponse)
}
