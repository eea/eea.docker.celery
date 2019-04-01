import os

# RabbitMQ Broker
broker_url = os.environ.get('CELERY_BROKER_URL', 'amqp://guest@rabbit')

# Redis Backend
result_backend = os.environ.get("CELERY_BACKEND_URL", "redis://redis")

# Timezone
timezone = os.environ.get("TZ", "Europe/Copenhagen")
