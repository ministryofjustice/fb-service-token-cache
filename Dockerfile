FROM python:3.11.1-alpine3.17

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

WORKDIR /python-docker

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

RUN chown -R 1001:appgroup /python-docker

USER 1001

ENV APP_PORT 3000
EXPOSE $APP_PORT

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=3000"]
