## Prerequisites

- Go 1.24.0 or higher
- Linux or macOS (Windows support available with additional setup)

## Installation

### Go Compiler Setup

#### Linux/macOS

1. **Download and install Go 1.24.0:**
   ```bash
   # Download Go 1.24.0
   wget https://golang.org/dl/go1.24.0.linux-amd64.tar.gz 
   
   # Remove any previous Go installation and extract
   sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.24.0.linux-amd64.tar.gz
   ```

2. **Set up environment variables:**
   
   Add the following to your shell configuration file (`.bashrc`, `.zshrc`, or `.profile`):
   ```bash
   # Add Go binary directory to PATH
   export PATH=$PATH:/usr/local/go/bin
   export GOPATH=$HOME/go
   export GOBIN=$GOPATH/bin
   ```

3. **Reload your shell configuration:**
   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```

4. **Verify installation:**
   ```bash
   go version
   # Should output: go version go1.24.0
   ```

#### Windows

```
sorry we don't do that here #(l + ratio + major skill issues)
```
*Just kidding! But seriously, use WSL2 or get a proper terminal. Your sanity will thank you later.*

### Protobuff tooling (Linux only)
1. **Install protobuf compiler:**
   ```bash
   # Fedora (use your package manager in place of dnf)   protoc --version

   sudo dnf install -y protobuf-compiler
   ```
2. **Verify the installation:**
   ```bash
   protoc --version
   # Output should be something like: libprotoc 3.19.6
   ```
3. **Install additional golang plugins:**
   ```bash
   go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
   go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
   ```
4. **Update your `PATH` so that the `protoc` compiler can find the plugins:**
   ```bash
   export PATH="$PATH:$(go env GOPATH)/bin"
   ```


<!-- ## Project Setup -->

## Project Structure

```
├── cmd/
│   └── server/          # Main application entry 
├── pkg/
│   └── grpcserver/      # Grpc server config  
├── internal/
│   ├── handlers/        # Request handlers
│   ├── services/        # Business logic
├── proto/               # Protocol Buffer definitions
├── .env.example         # env guideline
├── go.mod
├── go.sum
└── README.md
```

### Support

For additional help:
- Check the [Go documentation](https://golang.org/doc/)
- Visit [Protocol Buffers documentation](https://developers.google.com/protocol-buffers)
- Open an issue in this repository