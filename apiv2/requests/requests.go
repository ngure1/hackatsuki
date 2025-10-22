package requests

type DiagnosisRequest struct {
	Image  string `json:"image"`
	Prompt string `json:"promtp"`
}

type UpdatePhoneAndLocationRequest struct {
	PhoneNumber string  `json:"phone_number"`
	City        *string `json:"city"`
}

type SigninRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

//     FirstName    string  `json:"first_name"`
// LastName     string  `json:"last_name"`
// Email        *string `json:"email"        gorm:"unique;index"`
// PhoneNumber  *string `json:"phone_number" gorm:"unique;index"`
// PasswordHash string  `json:"-"

type SignUpRequest struct {
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Email     string `json:"email"`
	Password  string `json:"password"`
	// PhoneNumber *string `json:"phone_number"`
}

type CreateCommentRequest struct {
	Content         string `json:"content"`
	ParentCommentId *uint  `json:"parent_comment_id"`
}

// Blog requests
type CreateBlogRequest struct {
	Title   string `json:"title"`
	Content string `json:"content"`
}

type CreateBlogCommentRequest struct {
	Content         string `json:"content"`
	ParentCommentId *uint  `json:"parent_comment_id"`
}
