FROM ruby:3.1.2

# Throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install --path vendor/bundle

COPY . .

ENTRYPOINT [ "bundle" ]
CMD ["exec", "puma"]
