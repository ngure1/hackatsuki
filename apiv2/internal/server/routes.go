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
	bs := store.NewBlogStore(db)
	h := handlers.New(cs, ms, us, ps, bs)

	// Swagger route
	s.Get("/swagger/*", fiberSwagger.WrapHandler)

	//auth routes
	s.Post("/signin", h.SigninHandler)
	s.Post("/signup", h.SignupHandler)
	s.Get("/oauth/google", h.GoogleAuthHandler)
	s.Post("/oauth/google/v2", h.GoogleAuthMobileHandler)
	s.Get("/oauth/redirect", h.GoogleAuthRedirectHandler)

	s.Patch("/users", h.AuthMiddleware(), h.UpdatePhoneAndLocation)
	s.Get("/users/me", h.AuthMiddleware(), h.GetMe)

	//chat routes
	chatRoutes := s.Group("/chats")
	chatRoutes.Post("/", h.OptionalAuthMiddleware(), h.CreateChat)
	chatRoutes.Post("/:chatId/diagnosis", h.GetDiagnosis)
	chatRoutes.Post("/:chatId/share", h.AuthMiddleware(), h.ShareChatToCommunity)
	// protected
	chatRoutes.Get("/", h.AuthMiddleware(), h.GetChats)
	chatRoutes.Get("/:chatId/messages", h.AuthMiddleware(), h.GetChatMessages)

	// community post routes
	postRoutes := s.Group("/posts")
	postRoutes.Get("/", h.OptionalAuthMiddleware(), h.GetPosts)       // Use optional auth to get isLiked
	postRoutes.Get("/:postId", h.OptionalAuthMiddleware(), h.GetPost) // Use optional auth to get isLiked
	//protected
	postRoutes.Post("/", h.AuthMiddleware(), h.CreatePost)
	postRoutes.Delete("/:postId", h.AuthMiddleware(), h.DeletePost)
	postRoutes.Post("/:postId/likes", h.AuthMiddleware(), h.LikePost)
	postRoutes.Post("/:postId/comments", h.AuthMiddleware(), h.CommentOnPost)
	postRoutes.Get("/:postId/comments", h.AuthMiddleware(), h.GetComments)

	// blog routes
	blogRoutes := s.Group("/blogs")
	blogRoutes.Get("/", h.OptionalAuthMiddleware(), h.GetBlogs)       // Use optional auth to get isLiked
	blogRoutes.Get("/:blogId", h.OptionalAuthMiddleware(), h.GetBlog) // Use optional auth to get isLiked
	//protected
	blogRoutes.Post("/", h.AuthMiddleware(), h.CreateBlog)
	blogRoutes.Delete("/:blogId", h.AuthMiddleware(), h.DeleteBlog)
	blogRoutes.Post("/:blogId/likes", h.AuthMiddleware(), h.LikeBlog)
	blogRoutes.Post("/:blogId/comments", h.AuthMiddleware(), h.CommentOnBlog)
	blogRoutes.Get("/:blogId/comments", h.AuthMiddleware(), h.GetBlogComments)

	// comment routes
	commentRoutes := s.Group("/comments", h.AuthMiddleware())
	commentRoutes.Get("/:commentId/replies", h.GetCommentReplies)

	// blog comment routes
	blogCommentRoutes := s.Group("/blog-comments", h.AuthMiddleware())
	blogCommentRoutes.Get("/:commentId/replies", h.GetBlogCommentReplies)
}
