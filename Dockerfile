FROM python:3.9-slim-buster

ADD https://storage.googleapis.com/kubernetes-release/release/v1.18.2/bin/linux/amd64/kubectl /usr/local/bin/kubectl

RUN set -x && \
    apk add --no-cache curl ca-certificates && \
    chmod +x /usr/local/bin/kubectl && \
    # Create non-root user (with a randomly chosen UID/GUI).
    adduser kubectl -Du 2342 -h /config && \
    # Basic check it works.
    kubectl version --client

WORKDIR /python-docker

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
