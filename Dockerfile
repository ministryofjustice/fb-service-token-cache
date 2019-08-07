FROM ruby:2.6.3-alpine3.9

RUN apk add build-base bash libcurl sqlite sqlite-dev sqlite-libs tzdata

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
