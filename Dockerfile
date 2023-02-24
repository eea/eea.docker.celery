FROM python:3.7-alpine

RUN addgroup -g 500 celery \
 && adduser -S -D -G celery -u 500 celery \
 && apk add --no-cache \
    su-exec \
    bash \
    gcc \
    musl-dev \
 && pip install \
    redis=="3.2.1" \
    celery=="5.2.7" \
    celery-message-consumer=="1.2.1" \
    importlib-metadata=="4.13.0"

COPY celeryconfig.py /home/celery/
COPY tasks.py docker-entrypoint.sh /

WORKDIR /home/celery

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["celery", "-A", "tasks", "worker", "-l", "info"]
