[![CircleCI](https://circleci.com/gh/ministryofjustice/fb-service-token-cache/tree/main.svg?style=svg)](https://circleci.com/gh/ministryofjustice/fb-service-token-cache/tree/main)

# fb-service-token-cache

A stand-alone microservice providing a REST endpoint from which other Form
Builder platform apps (User Datastore, Submitter) can retrieve service tokens.

The authoritative source for tokens is a wrapper around `kubectl get secret`
calls, which use the `FB_ENVIRONMENT_SLUG` and `KUBECTL_*` environment variables
(see below) to construct the secret name and kubectl parameters. It will cache
successful calls in Elasticache Redis for SERVICE_TOKEN_CACHE_TTL seconds.

## Running tests

Prerequisites:

- Docker

```sh
make spec
```

## Deployment

Continuous Integration (CI) is enabled on this project via CircleCI.

On merge to main tests are executed and if green deployed to the test environment. This build can then be promoted to production
