FROM fabiocicerchia/nginx-lua

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

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY bin/health.sh /usr/bin/health.sh

RUN chown -R 1001:appgroup /etc/nginx/*
RUN chown -R 1001:appgroup /var/run/*
RUN chown -R 1001:appgroup /usr/bin/health.sh

USER 1001

ENV APP_PORT 3000
EXPOSE $APP_PORT
