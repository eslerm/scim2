.PHONY: help

# Module configuration
MODULE := github.com/elimity-com/scim
GOFILES := $(shell find . -type f -name '*.go' -not -path "./vendor/*")

# Default target - show help
help:  ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

#
# Testing targets
#

test:  ## Run tests with race detection
	go test -race -cover ./...

test-verbose:  ## Run tests with verbose output
	go test -race -cover -v ./...

test-coverage:  ## Run tests with coverage report
	go test -race -coverprofile=coverage.out -covermode=atomic ./...
	@echo "View with: go tool cover -html=coverage.out"

benchmark:  ## Run benchmarks
	go test -bench=. -benchmem ./...

#
# Code quality targets
#

fmt:  ## Format Go code
	@gofmt -w $(GOFILES)
	@goimports -w -local $(MODULE) $(GOFILES)

checkfmt:  ## Check code formatting (fails if unformatted)
	@test -z "$$(gofmt -l $(GOFILES))" || (echo "Error: unformatted files. Run 'make fmt'" && gofmt -l $(GOFILES) && exit 1)

vet:  ## Run go vet
	go vet ./...

lint:  ## Run linters
	golangci-lint run

vulncheck:  ## Check for known vulnerabilities
	govulncheck ./...

nilaway:  ## Run nilaway nil safety checker
	nilaway ./...

modernize:  ## Run modernize analyzer for modern Go patterns
	@go run golang.org/x/tools/go/analysis/passes/modernize/cmd/modernize@latest \
		./... \
		2>&1 | { grep ":" && echo "⚠️  Modernize suggestions found (review above)" || echo "✓ Modernize passed"; }

#
# Composite check targets
#

check-tidy:  ## Verify go.mod is tidy
	go mod tidy
	git diff --exit-code go.mod go.sum || (echo "ERROR: go.mod is not tidy. Run 'go mod tidy'" && exit 1)

check: checkfmt vet lint test check-tidy  ## Run all checks (fmt, vet, lint, test, tidy) - use before commit
	@echo "✓ All checks passed!"

check-full: check vulncheck  ## Run all checks including vulncheck (slower)
	@echo "✓ All checks including vulncheck passed!"

#
# Dependency management
#

tidy:  ## Tidy go.mod and go.sum
	go mod tidy

verify:  ## Verify dependency checksums
	go mod verify

#
# Setup targets
#

setup-golangci-lint:  ## Install golangci-lint
	go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest

setup-goimports:  ## Install goimports
	go install golang.org/x/tools/cmd/goimports@latest

setup-govulncheck:  ## Install govulncheck
	go install golang.org/x/vuln/cmd/govulncheck@latest

setup-nilaway:  ## Install nilaway
	go install go.uber.org/nilaway/cmd/nilaway@latest

setup: setup-golangci-lint setup-goimports setup-govulncheck setup-nilaway  ## Install all development tools

#
# Cleanup
#

clean:  ## Clean test artifacts
	rm -f coverage.out
	go clean -testcache

.DEFAULT_GOAL := help
