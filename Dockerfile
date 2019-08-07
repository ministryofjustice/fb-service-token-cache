FROM ruby:2.6.3-alpine3.9

RUN apk add build-base bash libcurl sqlite sqlite-dev sqlite-libs tzdata
ADD https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kubectl /usr/local/bin/kubectl

ENV HOME=/config

RUN set -x && \
    apk add --no-cache curl ca-certificates && \
    chmod +x /usr/local/bin/kubectl && \
    \
    # Create non-root user (with a randomly chosen UID/GUI).
    adduser kubectl -Du 2342 -h /config && \
    \
    # Basic check it works.
    kubectl version --client

RUN addgroup -g 1001 -S appgroup && \
  adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

COPY Gemfile* .ruby-version ./

ARG BUNDLE_FLAGS
RUN gem install bundler
RUN bundle install --no-cache

COPY . .

RUN chown -R 1001:appgroup /app

USER 1001

ENV APP_PORT 3000
EXPOSE $APP_PORT

ARG RAILS_ENV=production
CMD RAILS_ENV=${RAILS_ENV} bundle exec rails s -e ${RAILS_ENV} -p ${APP_PORT} --binding=0.0.0.0
