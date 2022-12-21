from flask import Flask
from markupsafe import escape
from flask_redis import FlaskRedis
from dotenv import load_dotenv
import os

app = Flask(__name__)
redis_client = FlaskRedis(app)
load_dotenv()


@app.route("/v3/applications/<service_slug>/namespaces/<namespace>")
def get_public_key(service_slug, namespace):
    key_name = key(escape(service_slug))
    print('getting key from redis')
    public_key = redis_client.get(key_name)

    if public_key is None:
        print('key not found in redis')
        k8s_public_key = get_k8s_public_key(service_slug, escape(namespace))
        if k8s_public_key is None:
            return 'public key does not exist'
        else:
            print('found key in k8s')
            print('saving key to redis')
            redis_client.set(key_name, k8s_public_key, ex=int(os.getenv('SERVICE_TOKEN_CACHE_TTL')))
            return k8s_public_key
    else:
        print('found key in redis')
        return public_key


def key(service_slug):
    return f"encoded-public-key-{service_slug}"


def get_k8s_public_key(service_slug, namespace):
    print('getting key from k8s')
    command = k8s_command(service_slug, namespace)
    stream = os.popen(command)
    output = stream.read()
    return output


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
    app.run(debug=True)
