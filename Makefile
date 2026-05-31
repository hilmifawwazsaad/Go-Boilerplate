.PHONY: run fmt lint vet tidy check

run:
	go run ./cmd/server

fmt:
	gofmt -w .
	goimports -w ./..

vet:
	go vet ./...

lint:
	golangci-lint run

tidy:
	go mod tidy

# Jalankan fmt + vet + lint sekaligus sebelum commit
check: fmt vet lint
