# Project apiv2
## Prerequisites

* Go 1.24.0 or higher
* Linux or macOS (Windows support available with additional setup)

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

---

### Air (Live reloading)

1. **Install air:**

   ```bash
   go install github.com/air-verse/air@latest
   ```

---

## Project Structure

```
├── cmd/
│   └── server/          # Main application entry 
├── internal/
│   ├── handlers/        # Request handlers
│   ├── services/        # Business logic
├── .env.example         # env guideline
├── go.mod
├── go.sum
└── README.md
```


## Getting Started

These instructions will help you set up and run the project locally for development and testing.

### Makefile Commands

Run build with tests:

```bash
make all
```

Build the application:

```bash
make build
```

Run the application:

```bash
make run
```

Live reload the application:

```bash
make watch
```

Run the test suite:

```bash
make test
```

Clean up binary from the last build:

```bash
make clean
```
Generate documentation
```bash
make docs
```

#### Api Documentation
Visit the [Swagger Endpoint](http://localhost:8080/swagger/index.html#/) to view the api documentation.


## Support

For additional help:

* Check the [Go documentation](https://golang.org/doc/)
* Open an issue in this repository
