package main

import (
	"context"
	"io"
	"log"

	diagnosispb "github.com/ngure1/hackatsuki/proto/diagnosis/generated/diagnosis"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	conn, err := grpc.NewClient("localhost:8080", grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("Error creating the client %s \n", err)
	}

	defer conn.Close()

	client := diagnosispb.NewDiagnosisClient(conn)

	stream, err := client.GetDiagnosis(context.Background(), &diagnosispb.DiagnosisRequest{
		ImageBytes: []byte("example"),
	})

	if err != nil {
		log.Fatalf("Error reading %s \n", err)
	}

	for {
		resp, err := stream.Recv()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatalf("Error receiving stream: %v", err)
		}

		log.Println("Received:", resp.ModelResponse)
	}
}
