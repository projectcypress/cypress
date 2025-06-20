############################################
#  🏗  Stage 1 – build gems + assets
############################################
FROM ruby:3.3.5-slim AS builder

# Essential OS packages (compile + JS pipeline)
# RUN apt-get update
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    build-essential libpq-dev git \
    nodejs npm tzdata

# Create the folder where you will store the MITRE SSL certificates
RUN mkdir -p /usr/local/share/ca-certificates
# Download the SSL certificates
RUN curl -L -o /usr/local/share/ca-certificates/MITRE-BA-NPE-CA-3-1.crt "http://pki.mitre.org/MITRE%20BA%20NPE%20CA-3(1).crt"
RUN curl -L -o /usr/local/share/ca-certificates/MITRE-BA-ROOT.crt "http://pki.mitre.org/MITRE%20BA%20ROOT.crt"
RUN curl -L -o /usr/local/share/ca-certificates/MITRE-NPE-CA1.crt "http://pki.mitre.org/MITRE-NPE-CA1.crt"
RUN curl -L -o /usr/local/share/ca-certificates/ZScaler_Root.crt "http://pki.mitre.org/ZScaler_Root.crt"
# Rebuild the system-wide SSL certificates bundle
RUN /usr/sbin/update-ca-certificates

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
#  🏃‍♂️  Stage 2 – runtime only (tiny image)
################################################
FROM ruby:3.3.5-slim

# ➜ install only the shared lib, not the dev headers
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    libcurl4 \
    # updates necessary to address cves
    openssl libssl3 libc6 libc-bin \ 
    tzdata
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

# clean up mitre certs from image
RUN rm -rf /usr/local/share/ca-certificates && /usr/sbin/update-ca-certificates

# Run as non-root
USER app

# Puma listens on 0.0.0.0:3000
EXPOSE 3000
CMD ["/usr/local/bin/docker_entrypoint.sh"]
