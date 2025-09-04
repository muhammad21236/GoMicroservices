# Detect OS (Windows_NT is what make sees on Windows)
ifeq ($(OS),Windows_NT)
	FRONT_CMD=set CGO_ENABLED=0&& go build -o
	GOOS_CMD=set GOOS=linux&& set CGO_ENABLED=0&& go build -o
	RUN_FRONT=start /B $(FRONT_END_BINARY).exe
	KILL_FRONT=taskkill /IM $(FRONT_END_BINARY).exe /F
else
	FRONT_CMD=CGO_ENABLED=0 go build -o
	GOOS_CMD=GOOS=linux CGO_ENABLED=0 go build -o
	RUN_FRONT=./$(FRONT_END_BINARY) &
	KILL_FRONT=pkill -SIGTERM -f "./$(FRONT_END_BINARY)" || true
endif

FRONT_END_BINARY=frontApp
BROKER_BINARY=brokerApp
AUTH_BINARY=authApp

## up: starts all containers in the background without forcing build
up:
	@echo "Starting Docker images..."
	docker-compose up -d
	@echo "Docker images started!"

## up_build: stops docker-compose (if running), builds all projects and starts docker compose
up_build: build_broker build_front build_auth
	@echo "Stopping docker images (if running...)"
	docker-compose down
	@echo "Building (when required) and starting docker images..."
	docker-compose up --build -d
	@echo "Docker images built and started!"

## down: stop docker compose
down:
	@echo "Stopping docker compose..."
	docker-compose down
	@echo "Done!"

## build_broker: builds the broker binary as a linux executable
build_broker:
	@echo "Building broker binary..."
	cd ./broker-service && $(GOOS_CMD) ${BROKER_BINARY} ./cmd/api
	@echo "Done!"

## build_auth: builds the auth binary as a linux executable
build_auth:
	@echo "Building auth binary..."
	cd ./authentication-service && $(GOOS_CMD) ${AUTH_BINARY} ./cmd/api
	@echo "Done!"

## build_front: builds the front end binary (OS specific for running locally)
build_front:
	@echo "Building front end binary..."
	cd ./front-end && $(FRONT_CMD) ${FRONT_END_BINARY} ./cmd/web
	@echo "Done!"

## start: starts the front end
start: build_front
	@echo "Starting front end"
	cd ./front-end && $(RUN_FRONT)

## stop: stop the front end
stop:
	@echo "Stopping front end..."
	@$(KILL_FRONT)
	@echo "Stopped front end!"
