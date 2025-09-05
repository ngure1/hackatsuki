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

func (h *Handler) SignupHandler(c *fiber.Ctx) error {
	body := new(SignUpRequest)
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
	if user != nil || err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "user with that email already exists",
			"error":   err.Error(),
		})
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(body.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error hashing password",
			"error":   err.Error(),
		})
	}

	newUser := models.User{
		FirstName:    body.FirstName,
		LastName:     body.LastName,
		Email:        &body.Email,
		PasswordHash: string(hashedPassword),
		// PhoneNumber: &body.PhoneNumber,
	}

	err = h.userStore.Create(newUser)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error creating user",
			"error":   err.Error(),
		})
	}

	return handleLogin(&newUser, body.Password)(c)
}

func handleLogin(user *models.User, password string) func(c *fiber.Ctx) error {
	return func(c *fiber.Ctx) error {
		if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
				"message": "Invalid email or password",
				"error":   err.Error(),
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
