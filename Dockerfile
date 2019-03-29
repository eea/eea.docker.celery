FROM python:3.7-alpine

RUN addgroup -g 500 celery \
 && adduser -S -D -G celery -u 500 celery \
 && apk add --no-cache su-exec \
 && pip install \
    redis=="3.2.1" \
    celery=="4.2.2" \
    flower=="0.9.3"

COPY celeryconfig.py /home/celery/
COPY tasks.py docker-entrypoint.sh /

EXPOSE 5555
WORKDIR /home/celery

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["celery", "-A", "tasks", "flower", "worker", "-l", "info", "-p", "5555"]
