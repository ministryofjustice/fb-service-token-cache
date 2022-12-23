FROM golang:1.19.4-alpine3.17

RUN apk add build-base bash libcurl sqlite sqlite-dev sqlite-libs tzdata

ADD https://storage.googleapis.com/kubernetes-release/release/v1.18.2/bin/linux/amd64/kubectl /usr/local/bin/kubectl

RUN set -x && \
    apk add --no-cache curl ca-certificates && \
    chmod +x /usr/local/bin/kubectl && \
    # Create non-root user (with a randomly chosen UID/GUI).
    adduser kubectl -Du 2342 -h /config && \
    # Basic check it works.
    kubectl version --client

RUN addgroup -g 1001 -S appgroup && \
  adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

COPY go.mod ./
COPY go.sum ./

RUN go mod download

COPY *.go ./

RUN go build -o /fb-service-token-cache

RUN chown -R 1001:appgroup /app

USER 1001

ENV APP_PORT 3000
EXPOSE $APP_PORT

CMD [ "/fb-service-token-cache"]
