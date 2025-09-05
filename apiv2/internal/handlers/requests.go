package handlers

type DiagnosisRequest struct {
	Image  string `json:"image"`
	Prompt string `json:"promtp"`
}

type SigninRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
