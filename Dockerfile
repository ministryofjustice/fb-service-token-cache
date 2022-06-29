FROM ruby:2.7.6-alpine3.16 AS base

RUN apk add build-base bash libcurl sqlite sqlite-dev sqlite-libs tzdata && rm -rf /var/cache/apk/*

FROM base AS dependencies

RUN apk add --update build-base

COPY Gemfile* .ruby-version ./
RUN bundle config set without 'development test' && bundle install --jobs=3 --retry=3

FROM base

ADD https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl /usr/local/bin/kubectl

RUN addgroup -g 1001 -S appgroup && adduser -u 1001 -S appuser -G appgroup

RUN set -x && \
    apk add --no-cache curl ca-certificates && \
    chmod +x /usr/local/bin/kubectl && \
    # Create non-root user (with a randomly chosen UID/GUI).
    adduser kubectl -Du 2342 -h /config && \
    # Basic check it works.
    kubectl version --client

WORKDIR /app

RUN chown appuser:appgroup /app

COPY --chown=appuser:appgroup --from=dependencies /usr/local/bundle/ /usr/local/bundle/
COPY --chown=appuser:appgroup . .

USER 1001

ENV APP_PORT 3000
EXPOSE $APP_PORT

RUN gem install bundler

ARG RAILS_ENV=production
CMD RAILS_ENV=${RAILS_ENV} bundle exec rails s -e ${RAILS_ENV} -p ${APP_PORT} --binding=0.0.0.0
