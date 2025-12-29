EXECUTABLE=git-server-poc

.PHONY: all
all: debug release

.PHONY: debug
debug:
	go build -v -o bin/$(EXECUTABLE) ./cmd/$(EXECUTABLE)/main.go

.PHONY: release
release:
	go build -v -o bin/$(EXECUTABLE) -ldflags="-s -w" -trimpath \
		./cmd/$(EXECUTABLE)/main.go

.PHONY: devenv_vm_setup
devenv_vm_setup:
	docker-compose -f scripts/docker-compose.yml up -d --build

.PHONY: devenv_vm_clean
devenv_vm_clean:
	docker-compose -f scripts/docker-compose.yml down
.PHONY: devenv
devenv: devenv_vm_setup

.PHONY: clean
clean: devenv_vm_clean
	rm -rf bin

.PHONY: test
test:
	go test ./...

.PHONY: format
format:
	go fmt ./...

.PHONY: lint
lint:
	go vet ./...
