default: all

.PHONY: all
all: build test run

.PHONY: build-api
build-api:
	cd apps/api && \
		nixpacks build . --name brewfile-api

.PHONY: build-website
build-website:
	cd apps/website && \
		docker build -t brewfile-website:latest .

.PHONY: build
build: build-api build-website

.PHONY: run
run:
	cd apps && \
    docker compose up -d && \
		open http://localhost:8080

.PHONY: test-website
test-website:
	cd apps/website && \
		npm run test:once

.PHONY: test-website-watch
test-website-watch:
	cd apps/website && \
		npm run test

.PHONY: test
test: test-website
