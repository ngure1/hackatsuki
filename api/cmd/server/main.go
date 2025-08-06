package main

import (
	"fmt"
	"log"
	"net"
	"os"

	"github.com/joho/godotenv"
	"github.com/ngure1/hackatsuki/pkg/grpcserver"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading env %s \n", err)
	}

	port := os.Getenv("PORT")
	listener, err := net.Listen("tcp", ":"+port)
	if err != nil {
		log.Fatalf("Error starting the server %s \n", err)
	}

	server := grpcserver.NewGrpcServer()

	fmt.Printf("Server Running on port %s...\n", port)
	err = server.Serve(listener)
	if err != nil {
		log.Fatalf("Error starting the grpc server %s \n", err)
	}
}
