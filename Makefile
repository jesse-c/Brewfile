default: all

.PHONY: all
all: build run

.PHONY: build-api
build-api:
	cd apps/api && \
		nixpacks build . --name brewfile-api

.PHONY: build-website
build-website:
	cd apps/website && \
		docker build -t brewfile-website:1.0.0 .

.PHONY: build
build: build-api build-website

.PHONY: run
run:
	cd apps && \
    docker compose up
