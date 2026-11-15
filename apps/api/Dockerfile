# syntax=docker/dockerfile:1
FROM ruby:3.4.12-slim-bookworm AS build

WORKDIR /app

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT=development:test

RUN apt-get update && apt-get install -y --no-install-recommends build-essential libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.5.7 --no-document \
    && bundle _2.5.7_ install --jobs 4 --retry 3 \
    && rm -rf /usr/local/bundle/cache

FROM ruby:3.4.12-slim-bookworm

WORKDIR /app

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT=development:test \
    RACK_ENV=production

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY . .

CMD ["sh", "-c", "exec bundle exec rackup config.ru -o 0.0.0.0 -p ${PORT:-3000}"]
