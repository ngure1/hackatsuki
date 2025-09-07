package server

import (
	"apiv2/internal/database"
	"apiv2/internal/handlers"
	"apiv2/internal/store"

	"github.com/gofiber/fiber/v2/middleware/cors"
)

func (s *FiberServer) RegisterFiberRoutes() {
	// Apply CORS middleware
	s.App.Use(cors.New(cors.Config{
		AllowOrigins:     "*",
		AllowMethods:     "GET,POST,PUT,DELETE,OPTIONS,PATCH",
		AllowHeaders:     "Accept,Authorization,Content-Type",
		AllowCredentials: false, // credentials require explicit origins
		MaxAge:           300,
	}))

	db := database.New()
	cs := store.NewChatStore(db)
	ms := store.NewMessageStore(db)
	us := store.NewUserStore(db)
	h := handlers.New(*cs, *ms, *us)

	//auth routes
	s.Post("/signin", h.SigninHandler)
	s.Post("/signup", h.SignupHandler)
	s.Get("/oauth/google", h.GoogleAuthHandler)
	s.Get("/oauth/redirect", h.GoogleAuthRedirectHandler)
	//chat routes
	chatRoutes := s.Group("/chats")
	chatRoutes.Post("/", h.OptionalAuthMiddleware(), h.CreateChat)
	chatRoutes.Post("/:chatId/diagnosis", h.GetDiagnosis)
	// protected
	chatRoutes.Get("/", h.AuthMiddleware(), h.GetChats)

}
