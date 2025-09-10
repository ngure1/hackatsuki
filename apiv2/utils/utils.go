package utils

func GetOffset(page, limit int) int {
	return (page - 1) * limit
}
