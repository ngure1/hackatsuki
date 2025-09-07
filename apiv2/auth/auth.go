package auth

import (
	"apiv2/internal/models"
	"os"
	"time"

	"github.com/golang-jwt/jwt"
)

type JwtClaims struct {
	UserId string
	Email  string
	Exp    time.Time
}

func GenerateToken(user *models.User) (string, error) {
	secret := []byte(os.Getenv("JWT_SECRET"))
	method := jwt.SigningMethodHS256
	claims := jwt.MapClaims{
		"userId": user.ID,
		"email":  user.Email,
		"exp":    time.Now().Add(7 * 24 * time.Hour).Unix(),
	}

	token, err := jwt.NewWithClaims(method, claims).SignedString([]byte(secret))
	if err != nil {
		return "", err
	}

	return token, nil
}
