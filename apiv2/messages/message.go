package messages

import "apiv2/internal/models"

type Store interface {
	Create(*models.Message) error
}
