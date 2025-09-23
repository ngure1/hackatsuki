package handlers

import (
	"apiv2/auth"
	"apiv2/internal/models"
	"encoding/json"
	"errors"
	"io"
	"strings"

	"github.com/gofiber/fiber/v2"
	"golang.org/x/oauth2"
	"gorm.io/gorm"
)

type GoogleUser struct {
	Email string `json:"email"`
	Name  string `json:"name"`
}

// GoogleAuthHandler godoc
// @Summary Google OAuth2 login
// @Description Redirects user to Google's OAuth2 consent screen for authentication.
// @Tags Auth
// @Produce json
// @Success 302 {string} string "Redirect to Google OAuth2"
// @Router /oauth/google [get]
func (h *Handler) GoogleAuthHandler(c *fiber.Ctx) error {
	url := auth.ConfigGoogle().AuthCodeURL("state", oauth2.SetAuthURLParam("prompt", "select_account"))
	return c.Redirect(url)
}

// GoogleAuthRedirectHandler godoc
// @Summary Google OAuth2 callback
// @Description Handles Google OAuth2 callback, retrieves user info, creates or logs in user, returns JWT token.
// @Tags Auth
// @Produce json
// @Param code query string true "Authorization code returned by Google"
// @Success 200 {object} map[string]string "access_token"
// @Failure 500 {object} map[string]string "Failed to exchange token or create user"
// @Router /oauth/redirect [get]
func (h *Handler) GoogleAuthRedirectHandler(c *fiber.Ctx) error {
	code := c.Query("code")
	c.UserContext()
	if code == "" {
		return c.Status(fiber.StatusInternalServerError).SendString("Url did not contain code")
	}
	token, err := auth.ConfigGoogle().Exchange(c.UserContext(), code)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to exchange token: " + err.Error())
	}
	client := auth.ConfigGoogle().
		Client(c.UserContext(), token)
	response, err := client.Get("https://www.googleapis.com/oauth2/v2/userinfo")
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to get user info: " + err.Error())
	}

	defer response.Body.Close()
	var gUser GoogleUser
	bytes, err := io.ReadAll(response.Body)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Error reading response body: " + err.Error())
	}
	err = json.Unmarshal(bytes, &gUser)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Error unmarshal json body " + err.Error())
	}

	existingUser, err := h.userStore.GetUserByEmail(gUser.Email)
	if err == nil && existingUser != nil {
		return HandleLogin(existingUser, "")(c)
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error looking up user",
			"error":   err.Error(),
		})
	}

	names := strings.Split(gUser.Name, " ")
	var newUser *models.User
	isPasswordSet := false

	if len(names) >= 2 {
		newUser = &models.User{
			FirstName:     names[0],
			LastName:      strings.Join(names[1:], ""),
			Email:         &gUser.Email,
			IsPasswordSet: &isPasswordSet,
		}
	} else {
		newUser = &models.User{
			FirstName:     names[0],
			LastName:      "",
			Email:         &gUser.Email,
			IsPasswordSet: &isPasswordSet,
		}
	}

	err = h.userStore.Create(*newUser)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(&fiber.Map{
			"message": "Error creating user",
			"error":   err.Error(),
		})
	}

	return HandleLogin(newUser, "")(c)
}
