default: all

.PHONY: all
all: build run

.PHONY: build
build:
	cd apps/api && \
		nixpacks build . --name brewfile-api
	cd apps/website && \
		docker build -t brewfile-website:1.0.0 .

.PHONY: run
run:
	cd apps && \
    docker compose up
