package handlers

import (
	"apiv2/auth"
	"apiv2/internal/models"
	"apiv2/requests"
	"errors"

	"github.com/gofiber/fiber/v2"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// SigninHandler godoc
// @Summary Sign in a user
// @Description Authenticate a user with email and password, returns a JWT token on success.
// @Tags Auth
// @Accept json
// @Produce json
// @Param request body requests.SigninRequest true "User credentials"
// @Success 200 {object} map[string]string "access_token"
// @Failure 400 {object} map[string]string "Invalid request or wrong credentials"
// @Failure 401 {object} map[string]string "Unauthorized - user not found"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /signin [post]
func (h *Handler) SigninHandler(c *fiber.Ctx) error {
	body := new(requests.SigninRequest)

	if err := c.BodyParser(body); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "error decoding body",
			"error":   err.Error(),
		})
	}

	if body.Email == "" || body.Password == "" {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "Password or email cannot be empty",
			"error":   "Vallidation failed",
		})
	}

	user, err := h.userStore.GetUserByEmail(body.Email)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return c.Status(fiber.StatusUnauthorized).JSON(&fiber.Map{
				"message": "No account found with that email",
				"error":   err.Error(),
			})
		}

		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error querying user",
			"error":   err.Error(),
		})
	}

	if user == nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Unexpected: user is nil but no error",
		})
	}

	return HandleLogin(user, body.Password)(c)
}

// SignupHandler godoc
// @Summary Register a new user
// @Description Creates a new user account with email and password, returns JWT token on success.
// @Tags Auth
// @Accept json
// @Produce json
// @Param request body requests.SignUpRequest true "User registration data"
// @Success 200 {object} map[string]string "access_token"
// @Failure 400 {object} map[string]string "Validation error or user already exists"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /signup [post]
func (h *Handler) SignupHandler(c *fiber.Ctx) error {
	body := new(requests.SignUpRequest)
	// todo : imrove error handling here
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
	if user != nil || (err != nil && !errors.Is(err, gorm.ErrRecordNotFound)) {
		return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
			"message": "user with that email already exists",
			"error":   err.Error(),
		})
	}

	hashedPasswordBytes, err := bcrypt.GenerateFromPassword([]byte(body.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error hashing password",
			"error":   err.Error(),
		})
	}

	hashedPassword := string(hashedPasswordBytes)
	isPasswordSet := true
	newUser := models.User{
		FirstName:     body.FirstName,
		LastName:      body.LastName,
		Email:         &body.Email,
		PasswordHash:  &hashedPassword,
		IsPasswordSet: &isPasswordSet,
		// PhoneNumber: &body.PhoneNumber,
	}

	err = h.userStore.Create(newUser)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error creating user",
			"error":   err.Error(),
		})
	}

	return HandleLogin(&newUser, body.Password)(c)
}

func HandleLogin(user *models.User, password string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		if *user.IsPasswordSet {
			if err := bcrypt.CompareHashAndPassword([]byte(*user.PasswordHash), []byte(password)); err != nil {
				return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
					"message": "Invalid email or password",
					"error":   err.Error(),
				})
			}
		} else {
			if password != "" {
				return c.Status(fiber.StatusBadRequest).JSON(&fiber.Map{
					"message": "This account was registered via google",
					"error":   "you cannot sign in using regular email and password",
				})
			}
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
