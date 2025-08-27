# syntax=docker/dockerfile:1

FROM clojure:tools-deps-1.11.3.1456-bookworm-slim AS build

RUN apt-get update && apt-get install -y apt-transport-https curl
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get install -y nodejs
RUN node -v

COPY ./ /usr/app

WORKDIR /usr/app

RUN npm install
RUN npm run release

FROM caddy:2.10.0-alpine AS run

COPY --from=build /usr/app/public /usr/share/caddy
COPY Caddyfile /etc/caddy/Caddyfile
