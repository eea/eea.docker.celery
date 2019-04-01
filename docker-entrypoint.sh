#!/bin/sh

cp /tasks.py /home/celery/

if [ ! -z "$CELERY_TASKS" ]; then
  echo "$CELERY_TASKS" >> tasks.py
fi

PARAMS=""

# Add Github Auth
if [ ! -z "$FLOWER_OAUTH2_KEY" ]; then
  if [ ! -z  "$FLOWER_OAUTH2_SECRET" ]; then
    if [ ! -z "$FLOWER_OAUTH2_REDIRECT_URI" ]; then
      PARAMS="$PARAMS --auth_provider=flower.views.auth.GithubLoginHandler"
    fi
  fi
fi

if [ "$1" == "celery" ]; then
  exec su-exec celery "$@$PARAMS"
fi

exec su-exec celery "$@"
