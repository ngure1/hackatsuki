package services

import (
	"crypto/rand"
	"time"

	diagnosispb "github.com/ngure1/hackatsuki/proto/diagnosis/generated/diagnosis"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type diagnosisServer struct {
	diagnosispb.UnimplementedDiagnosisServer
}

func NewDiagnosisService() *diagnosisServer {
	return &diagnosisServer{}
}

func (s *diagnosisServer) GetDiagnosis(
	req *diagnosispb.DiagnosisRequest,
	stream grpc.ServerStreamingServer[diagnosispb.DiagnosisResponse],
) error {

	for {
		select {
		case <-stream.Context().Done():
			return status.Error(codes.Canceled, "Stream has ended")
		default:
			//make api call
			time.Sleep(4 * time.Second)

			modelResponse := rand.Text()
			err := stream.SendMsg(&diagnosispb.DiagnosisResponse{
				ModelResponse: modelResponse,
			})

			if err != nil {
				return status.Error(codes.Canceled, "Stream has ended")
			}
		}
	}
}
