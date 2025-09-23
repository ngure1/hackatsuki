package server

import (
	"apiv2/internal/database"
	_ "apiv2/internal/docs"
	"apiv2/internal/handlers"
	"apiv2/internal/store"

	"github.com/gofiber/fiber/v2/middleware/cors"
	fiberSwagger "github.com/swaggo/fiber-swagger"
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
	s.App.Static("/public", "./media")

	db := database.New()
	cs := store.NewChatStore(db)
	ms := store.NewMessageStore(db)
	us := store.NewUserStore(db)
	ps := store.NewPostStore(db)
	h := handlers.New(cs, ms, us, ps)

	// Swagger route
	s.Get("/swagger/*", fiberSwagger.WrapHandler)

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

	// comunity post routes
	postRoutes := s.Group("/posts")
	postRoutes.Get("/", h.GetPosts)
	postRoutes.Get("/:postId", h.GetPost)
	//protected
	postRoutes.Post("/", h.AuthMiddleware(), h.CreatePost)
	postRoutes.Post("/:postId/likes", h.AuthMiddleware(), h.LikePost)
	postRoutes.Post("/:postId/comments", h.AuthMiddleware(), h.CommentOnPost)
	postRoutes.Get("/:postId/comments", h.AuthMiddleware(), h.GetComments)

	// comment  routes
	commentRoutes := s.Group("/comments", h.AuthMiddleware())
	commentRoutes.Get("/:commentId/replies", h.GetCommentReplies)
}
