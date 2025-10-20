package handlers

import (
	"apiv2/requests"

	"github.com/gofiber/fiber/v2"
)

// UpdatePhoneNumber godoc
// @Summary Update the users phone number
// @Description Updates the logged in users phone number
// @Tags Users
// @Accept  json
// @Produce  json
// @Param phoneNumber body requests.UpdatePhoneNumberRequest true "Phone number to use"
// @Success 200
// @Failure 401 {object} map[string]string "Unauthenticated
// @Failure 404 {object} map[string]string "User not found"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /users [patch]
func (h *Handler) UpdatePhoneNumber(c *fiber.Ctx) error {
	userId := c.Locals("userId").(uint)

	body := new(requests.UpdatePhoneNumberRequest)

	if err := c.BodyParser(body); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error decoding body",
			"error":   err.Error(),
		})
	}

	if body.PhoneNumber == "" {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Phone number cannot be empty",
			"error":   "Vallidation failed",
		})
	}

	err := h.userStore.UpdatePhoneNumber(userId, body.PhoneNumber)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error updating phone number",
			"error":   err.Error(),
		})
	}

	return c.SendStatus(fiber.StatusOK)
}
