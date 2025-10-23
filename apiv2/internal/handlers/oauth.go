package handlers

import (
	"apiv2/auth"
	"apiv2/internal/models"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
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

// GoogleAuthMobileHandler godoc
// @Summary Google OAuth2 mobile token verification
// @Description Verifies Google ID token from mobile app and returns JWT token
// @Tags Auth
// @Accept json
// @Produce json
// @Param id_token body map[string]string true "Google ID Token" example({"id_token": "eyJhbGciOiJSUzI1NiIs..."})
// @Success 200 {object} map[string]string "access_token"
// @Failure 400 {object} map[string]string "Invalid request"
// @Failure 401 {object} map[string]string "Invalid token"
// @Failure 500 {object} map[string]string "Server error"
// @Router /oauth/google/v2 [post]
func (h *Handler) GoogleAuthMobileHandler(c *fiber.Ctx) error {
	var reqBody map[string]string
	if err := c.BodyParser(&reqBody); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid request body",
			"error":   err.Error(),
		})
	}

	idToken, exists := reqBody["id_token"]
	if !exists || idToken == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Missing id_token in request body",
		})
	}

	// Verify the ID token with Google
	googleUser, err := h.verifyGoogleIDToken(idToken)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"message": "Invalid Google ID token",
			"error":   err.Error(),
		})
	}

	// Check if user already exists
	existingUser, err := h.userStore.GetUserByEmail(googleUser.Email)
	if err == nil && existingUser != nil {
		return HandleLogin(existingUser, "")(c)
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error looking up user",
			"error":   err.Error(),
		})
	}

	// Create new user
	names := strings.Split(googleUser.Name, " ")
	var newUser *models.User
	isPasswordSet := false

	if len(names) >= 2 {
		newUser = &models.User{
			FirstName:     names[0],
			LastName:      strings.Join(names[1:], " "),
			Email:         &googleUser.Email,
			IsPasswordSet: &isPasswordSet,
		}
	} else {
		newUser = &models.User{
			FirstName:     names[0],
			LastName:      "",
			Email:         &googleUser.Email,
			IsPasswordSet: &isPasswordSet,
		}
	}

	err = h.userStore.Create(*newUser)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error creating user",
			"error":   err.Error(),
		})
	}

	return HandleLogin(newUser, "")(c)
}

// verifyGoogleIDToken verifies the Google ID token and extracts user information
func (h *Handler) verifyGoogleIDToken(idToken string) (*GoogleUser, error) {
	// Google's token info endpoint - simpler approach
	url := fmt.Sprintf("https://oauth2.googleapis.com/tokeninfo?id_token=%s", idToken)

	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to verify token with Google: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("token verification failed with status: %d", resp.StatusCode)
	}

	var tokenInfo struct {
		Email         string `json:"email"`
		EmailVerified string `json:"email_verified"`
		Name          string `json:"name"`
		Picture       string `json:"picture"`
		GivenName     string `json:"given_name"`
		FamilyName    string `json:"family_name"`
		Aud           string `json:"aud"`
		Iss           string `json:"iss"`
		Sub           string `json:"sub"`
		Exp           string `json:"exp"`
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %v", err)
	}

	if err := json.Unmarshal(body, &tokenInfo); err != nil {
		return nil, fmt.Errorf("failed to parse token info: %v", err)
	}

	// Verify the audience (should match your Google Client ID)
	expectedClientID := os.Getenv("GOOGLE_CLIENT_ID")
	if tokenInfo.Aud != expectedClientID {
		return nil, fmt.Errorf("invalid audience: expected %s, got %s", expectedClientID, tokenInfo.Aud)
	}

	// Verify the issuer
	if tokenInfo.Iss != "accounts.google.com" && tokenInfo.Iss != "https://accounts.google.com" {
		return nil, fmt.Errorf("invalid issuer: %s", tokenInfo.Iss)
	}

	// Email should be verified
	if tokenInfo.EmailVerified != "true" {
		return nil, fmt.Errorf("email not verified by Google")
	}

	return &GoogleUser{
		Email: tokenInfo.Email,
		Name:  tokenInfo.Name,
	}, nil
}
