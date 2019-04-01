FROM python:3.6-alpine

RUN addgroup -g 500 celery \
 && adduser -S -D -G celery -u 500 celery \
 && apk add --no-cache su-exec \
 && pip install \
    redis=="3.2.1" \
    celery=="4.2.2" \
    flower=="0.9.3" \
    celery-message-consumer=="1.1.1"

COPY celeryconfig.py /home/celery/
COPY tasks.py docker-entrypoint.sh /

EXPOSE 5555
WORKDIR /home/celery

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["celery", "worker", "-A", "tasks", "-l", "info"]
