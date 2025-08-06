package main

import (
	"fmt"
	"log"
	"net"

	"github.com/ngure1/hackatsuki/pkg/grpcserver"
)

func main() {
	listener, err := net.Listen("tcp", ":8080")
	if err != nil {
		log.Fatalf("Error starting the server %s \n", err)
	}

	server := grpcserver.NewGrpcServer()

	fmt.Printf("Server Running on port 8080...\n")
	err = server.Serve(listener)
	if err != nil {
		log.Fatalf("Error starting the grpc server %s \n", err)
	}
}
