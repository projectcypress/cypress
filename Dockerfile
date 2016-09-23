FROM ruby:2.2

RUN apt-get update \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES 1

ADD Gemfile /rails/cypress/Gemfile
ADD Gemfile.lock /rails/cypress/Gemfile.lock

WORKDIR /rails/cypress

RUN bundle install --without development test

ADD . /rails/cypress

RUN chmod 755 /rails/cypress/rails-entrypoint.sh

EXPOSE 3000
