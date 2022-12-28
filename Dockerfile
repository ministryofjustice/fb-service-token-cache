FROM rust:alpine3.16

RUN apk add build-base bash libcurl sqlite sqlite-dev sqlite-libs tzdata openssl openssl-dev

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

# WORKDIR /rust-docker
# RUN cargo init
# COPY Cargo.toml /rust-docker/Cargo.toml
# RUN cargo fetch
# COPY . /rust-docker
COPY ./ ./

RUN cargo build --release

RUN chown -R 1001:appgroup ./target

USER 1001

ENV APP_PORT 3000
EXPOSE $APP_PORT

CMD [ "./target/release/fb-service-token-cache"]
