package handlers

type DiagnosisRequest struct {
	Image  string `json:"image"`
	Prompt string `json:"promtp"`
}
