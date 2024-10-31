from flask import Flask
from redis import Redis, RedisError
import os
import socket


def get_secret(path):
    with open(path, 'r') as file:
        return file.read().strip()


# Determine the runtime environment and set Redis credentials accordingly
if os.environ.get("CREATOR") == "Azure_Container_Instance":
    redis_host = os.environ.get("REDIS_HOST", "localhost")
    redis_password = os.environ.get("REDIS_PASSWORD", "")
else:
    redis_host = get_secret(os.environ.get(
        "REDIS_HOST", "/mnt/secrets-store/redis-url"))
    redis_password = get_secret(os.environ.get(
        "REDIS_PASSWORD", "/mnt/secrets-store/redis-password"))

redis_port = os.environ.get("REDIS_PORT", "6379")
redis_ssl = os.environ.get(
    "REDIS_SSL_MODE", "False").lower() in ("true", "1", "yes")


redis = Redis(host=redis_host, port=redis_port, db=0,
              password=redis_password, ssl=redis_ssl)

app = Flask(__name__)


@app.route("/")
def hello():
    try:
        visits = redis.incr("counter")
    except RedisError:
        visits = "<i>cannot connect to Redis, counter disabled</i>"

    html = "<h3>Hello from {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" \
           "<b>Visits:</b> {visits}"

    return html.format(name=os.getenv("CREATOR"), hostname=socket.gethostname(),
                       visits=visits)


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
