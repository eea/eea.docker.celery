#!/bin/sh

cp /tasks.py /home/celery/

if [ ! -z "$ADDONS" ]; then
  pip install $ADDONS
fi

if [ ! -z "$TASKS" ]; then
  echo "$TASKS" >> tasks.py
fi

exec su-exec celery "$@"
