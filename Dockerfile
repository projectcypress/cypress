############################################
#  🏗  Stage 1 – build gems + assets
############################################
FROM ruby:3.3.8-slim AS builder

# Essential OS packages (compile + JS pipeline)
# RUN apt-get update
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    build-essential libpq-dev git \
    nodejs npm tzdata \
    libyaml-dev pkg-config

# App directory & non-root user
ENV APP_HOME=/app
RUN groupadd -g 1001 app && useradd -u 1001 -g app -m -d $APP_HOME app
WORKDIR $APP_HOME

# Ruby deps first (enables layer caching)
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local frozen true \
 && bundle config set --local without 'development test production' \
 && bundle install --jobs 4 --retry 3

COPY . .

COPY docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod +x /usr/local/bin/docker_entrypoint.sh
RUN RAILS_ENV=production DISABLE_DB=true SECRET_KEY_BASE=precompile_only bundle exec rake assets:precompile

################################################
#  🏃‍♂️  Stage 2 – production image
################################################
FROM ruby:3.3.8-slim AS prod

# ➜ install only the shared lib, not the dev headers
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    libcurl4 \
    # updates necessary to address cves
    openssl libssl3 libc6 libc-bin \ 
    tzdata procps
    # nodejs

# Copy the built app & cached gems from the builder
ENV APP_HOME=/app
RUN groupadd -g 1001 app && useradd -u 1001 -g app -m -d $APP_HOME app
WORKDIR $APP_HOME
COPY --from=builder --chown=app:app ${APP_HOME} ${APP_HOME}
COPY --from=builder --chown=app:app /usr/local/bin/docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
COPY --from=builder /usr/local/bundle /usr/local/bundle
RUN mkdir -p /app/tmp/bundles && chown -R app:app /app

# Environment hints for Rails & Bundler
ENV RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    BUNDLE_WITHOUT='development test production'

# Run as non-root
USER app

# Puma listens on 0.0.0.0:3000
EXPOSE 3000
CMD ["/usr/local/bin/docker_entrypoint.sh"]

############################################
#  🏗  Stage 3 – development environment
############################################
FROM ruby:3.3.8-slim AS dev

# Essential OS packages (compile + JS pipeline)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    build-essential libpq-dev git \
    nodejs npm tzdata \
    libyaml-dev pkg-config procps

# Copy only Gemfiles to install dependencies early
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Environment setup for development
ENV RAILS_ENV=development \
    BUNDLE_WITHOUT='test' \
    PORT=3000

# App working directory
WORKDIR /app

# Mount source files for hot reloading
COPY . .

# Install foreman for managing processes
RUN gem install foreman

# Expose port for development
EXPOSE 3000

# Command to start the application with foreman
CMD ["foreman", "start"]
