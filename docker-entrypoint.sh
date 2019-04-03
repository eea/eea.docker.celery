#!/bin/bash
set -e

touch requirements.txt
if [ ! -z "$REQUIREMENTS" ]; then
  echo "$REQUIREMENTS" > requirements.txt
fi

touch constraints.txt
if [ ! -z "$CONSTRAINTS" ]; then
  echo "$CONSTRAINTS" > constraints.txt
fi

pip install -r requirements.txt -c constraints.txt

cp /tasks.py /home/celery/
if [ ! -z "$TASKS" ]; then
  echo "$TASKS" >> tasks.py
fi

if [[ "$1" == "-"* ]]; then
  exec su-exec celery celery "$@"
fi

exec su-exec celery "$@"
