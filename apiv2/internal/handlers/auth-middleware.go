package handlers

import (
	"errors"
	"fmt"
	"os"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt"
	"gorm.io/gorm"
)

const authHeaderPrefix = "Bearer"

func (h *Handler) AuthMiddleware() fiber.Handler {
	return func(c *fiber.Ctx) error {
		authHeader := c.Get(fiber.HeaderAuthorization)

		if authHeader == "" {

			return c.Status(fiber.StatusUnauthorized).JSON(&fiber.Map{
				"message": "Unauthorized",
				"error":   "empty authorization header",
			})
		}

		authHeaderParts := strings.Split(strings.Trim(authHeader, " "), " ")

		if len(authHeaderParts) != 2 || authHeaderParts[0] != authHeaderPrefix {

			return c.Status(fiber.StatusUnauthorized).JSON(&fiber.Map{
				"message": "Unauthorized",
				"error":   "invalid token parts",
			})
		}

		tokenString := authHeaderParts[1]
		secret := os.Getenv("JWT_SECRET")

		token, err := jwt.Parse(tokenString, func(t *jwt.Token) (any, error) {
			if t.Method.Alg() != jwt.GetSigningMethod("HS256").Alg() {
				return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
			}
			return []byte(secret), nil
		})

		if err != nil || !token.Valid {

			return c.Status(fiber.StatusUnauthorized).JSON(&fiber.Map{
				"message": "Unauthorized",
				"error":   fmt.Sprintf("invalid token : %s", err.Error()),
			})
		}

		userId := uint(token.Claims.(jwt.MapClaims)["userId"].(float64))

		if _, err := h.userStore.GetUserById(userId); errors.Is(err, gorm.ErrRecordNotFound) {

			return c.Status(fiber.StatusUnauthorized).JSON(&fiber.Map{
				"message": "Unauthorized",
				"error":   "user not found in the db",
			})
		}

		c.Locals("userId", userId)

		return c.Next()
	}
}
