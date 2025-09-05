package handlers

import (
	"apiv2/auth"
	"apiv2/internal/models"

	"github.com/gofiber/fiber/v2"
	"golang.org/x/crypto/bcrypt"
)

func (h *Handler) SigninHandler(c *fiber.Ctx) error {
	body := new(SigninRequest)

	if err := c.BodyParser(body); err != nil {
		return c.SendStatus(fiber.StatusInternalServerError)
	}

	if body.Email == "" || body.Password == "" {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Password or email cannot be empty",
			"error":   "Vallidation failed",
		})
	}

	user, err := h.userStore.GetUserByEmail(body.Email)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Error finding user by email",
			"error":   err,
		})
	}

	return handleLogin(user, body.Password)(c)
}

func (h *Handler) SignupHandler(ctx *fiber.Ctx) error {

	return nil
}

func handleLogin(user *models.User, password string) func(c *fiber.Ctx) error {
	return func(c *fiber.Ctx) error {
		if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
				"message": "Invalid email or password",
				"error":   err,
			})
		}

		token, err := auth.GenerateToken(user)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
				"message": "Error generating jwt token",
				"error":   err.Error(),
			})
		}

		return c.Status(fiber.StatusOK).JSON(&fiber.Map{
			"access_token": token,
		})

	}
}
