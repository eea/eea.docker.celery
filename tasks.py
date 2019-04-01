""" Celery tasks
"""
import celeryconfig
from celery import Celery
from event_consumer import message_handler
from event_consumer.handlers import AMQPRetryConsumerStep

app = Celery("tasks")
app.config_from_object(celeryconfig)
app.steps['consumer'].add(AMQPRetryConsumerStep)

## --- Celery tasks will be inserted here by docker-entrypoint from CELERY_TASKS env--- ##
