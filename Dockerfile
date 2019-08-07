FROM ruby:2.6.3-alpine3.9

RUN apk add build-base bash libcurl sqlite sqlite-dev sqlite-libs tzdata

# https://kubernetes.io/docs/tasks/tools/install-kubectl/
# RUN apt-get update && apt-get install -y apt-transport-https
# RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# RUN touch /etc/apt/sources.list.d/kubernetes.list
# RUN echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
# RUN apt-get update
# RUN apt-get install -y kubectl

RUN apk update && apk add curl git

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.1/bin/linux/amd64/kubectl
RUN chmod u+x kubectl && mv kubectl /bin/kubectl


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
