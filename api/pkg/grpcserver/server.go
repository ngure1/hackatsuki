package grpcserver

import (
	"github.com/ngure1/hackatsuki/internal/services"
	diagnosispb "github.com/ngure1/hackatsuki/proto/diagnosis/generated/diagnosis"
	"google.golang.org/grpc"
)

func NewGrpcServer() *grpc.Server {
	serverRegister := grpc.NewServer()

	// create services
	diagnosisService := services.NewDiagnosisService()

	//register services
	diagnosispb.RegisterDiagnosisServer(serverRegister, diagnosisService)

	return serverRegister
}
