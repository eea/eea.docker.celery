import celeryconfig
from celery import Celery

app = Celery()
app.config_from_object(celeryconfig)

## --- Celery tasks will be inserted here by docker-entrypoint from CELERY_TASKS env--- ##
