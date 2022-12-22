from flask import Flask, jsonify
from markupsafe import escape
from dotenv import load_dotenv
from sentry_sdk import capture_message
import redis
import sentry_sdk
import os

app = Flask(__name__)
load_dotenv()

REDIS_PROTOCOL = os.getenv("REDIS_PROTOCOL")
REDIS_AUTH_TOKEN = os.getenv("REDIS_AUTH_TOKEN")
REDIS_URL = f"{REDIS_PROTOCOL}{os.getenv('REDIS_URL')}"

redis_client = redis.Redis.from_url(url=REDIS_URL, password=REDIS_AUTH_TOKEN)

if os.getenv("SENTRY_DSN") != '':
    sentry_sdk.init(
        dsn=os.getenv("SENTRY_DSN")
    )


@app.route("/health")
def health():
    return 'healthy'


@app.route("/readiness")
def ready():
    return 'ready'


@app.route("/service/v2/<service_slug>")
def service_public_key(service_slug):
    print('getting key for service')
    return get_public_key(service_slug, os.getenv('KUBECTL_SERVICES_NAMESPACE'))


@app.route("/v3/applications/<service_slug>/namespaces/<namespace>")
def application_public_key(service_slug, namespace):
    print('getting key for app')
    return get_public_key(service_slug, namespace)


def get_public_key(service_slug, namespace):
    key_name = key(escape(service_slug))
    print('getting key from redis')

    try:
      public_key = redis_client.get(key_name)
      if public_key is None:
          print('key not found in redis')
          k8s_public_key = get_k8s_public_key(service_slug, escape(namespace))
          if k8s_public_key is None:
              capture_message(f"{service_slug} not found in k8s")
              return jsonify({ "token": 'public key does not exist' })
          else:
              print('found key in k8s')
              print('saving key to redis')
              redis_client.set(key_name, k8s_public_key, ex=int(os.getenv('SERVICE_TOKEN_CACHE_TTL')))
              return jsonify({ "token": k8s_public_key.replace("'", "") })
      else:
          print('found key in redis')
          return jsonify({ "token": public_key.decode("utf-8").replace("'", "") })
    except Exception as e:
      capture_message(str(e))
      return jsonify({ "token": '' })


def key(service_slug):
    return f"encoded-public-key-{service_slug}"


def get_k8s_public_key(service_slug, namespace):
    print('getting key from k8s')
    try:
      command = k8s_command(service_slug, namespace)
      stream = os.popen(command)
      output = stream.read()
      return output
    except:
      capture_message(f"k8s could not get key {service_slug}")
      return None


def k8s_command(service_slug, namespace):
    full_command = [
        'kubectl',
        'get',
        'configmaps',
        '-o',
        "jsonpath='{.data.ENCODED_PUBLIC_KEY}'",
        f"fb-{service_slug}-config-map",
        f"--namespace={namespace}",
        f"--token={os.getenv('KUBECTL_BEARER_TOKEN')}",
        '--ignore-not-found=true'
    ]
    return ' '.join(full_command)


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
