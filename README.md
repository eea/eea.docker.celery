## Celery Docker Image (w/ support for non-Celery tasks/messages)

Celery is an open source asynchronous task queue/job queue based on distributed message passing.
It is focused on real-time operation, but supports scheduling as well.

This image allows you to run Celery worker together with your custom **Python dependencies**
by passing **requirements** and **contraints** via environment variables `REQUIREMENTS` respectively `CONSTRAINTS`.
It also has the ability to consume **vanilla AMQP messages** (i.e. **not** Celery tasks) based on
[celery-message-consumer](https://pypi.org/project/celery-message-consumer/)

This image is generic, thus you can obviously re-use it within your non-related EEA projects.

  - Celery **4.3.0**
  - Python **3.7**
  - Alpine **3.9**


### Supported tags and respective Dockerfile links

  - `:latest` [*Dockerfile*](https://github.com/eea/eea.docker.celery/blob/master/Dockerfile)


### Stable and immutable tags

  - `:4.3-1.0` [*Dockerfile*](https://github.com/eea/eea.docker.celery/tree/4.3-1.0/Dockerfile)

See [older versions](https://github.com/eea/eea.docker.celery/releases)


### Changes

 - [CHANGELOG.md](https://github.com/eea/eea.docker.celery/blob/master/CHANGELOG.md)


### Base docker image

 - [hub.docker.com](https://hub.docker.com/r/eeacms/celery)


### Source code

  - [github.com](http://github.com/eea/eea.docker.celery)


### Installation

1. Install [Docker](https://www.docker.com/)
2. Install [Docker Compose](https://docs.docker.com/compose/install/).

## Usage


### Run with Docker Compose

Here is a basic example of a `docker-compose.yml` file using the `eeacms/celery` docker image:

```yaml
  version: "3"
  services:
    celery:
      image: eeacms/celery:4.3-1.0
      environment:
        TZ: "Europe/Copenhagen"
        CELERY_BROKER_URL: "amqp://admin:admin@rabbit"
        CELERY_BACKEND_URL: "redis://redis"
        REQUIREMENTS: |
          nltk
          requests
        CONSTRAINTS: |
          nltk==3.4
          requests==2.21.0
        TASKS: |
          import requests
          import nltk
          nltk.download('punkt')

          @message_handler('nltk_queue')
          def handle_nltk(body):
            tokens = nltk.word_tokenize(body)
            print(tokens)
            return tokens

          @message_handler('req_queue')
          def handle_req(url):
            res = requests.get(url)
            status = res.status_code
            print("Got %s status code while calling %s" % (status, url))
            return status
      depends_on:
      - redis
      - rabbit

    redis:
      image: redis:5

    rabbit:
      image: rabbitmq:management-alpine
      ports:
      - "15672:15672"
      environment:
        TZ: Europe/Copenhagen
        RABBITMQ_DEFAULT_USER: admin
        RABBITMQ_DEFAULT_PASS: admin
```


Run your stack with `docker-compose` and check the logs to see when the application is ready to handle requests:

```
  $ docker-compose up -d
  $ docker-compose logs -f
```

The RabbitMQ management interface can be checked in a browser, navigating to http://localhost:15672 (user/password `admin:admin`)

You can also start Celery inside container with different arguments by passing them via Docker `command`. See:

```
  $ docker run -it --rm eeacms/celery --help
```

## Sending messages to RabbitMQ

You can either add Celery to your application and use it to add tasks by using the `@add.task` decorator (see [Celery docs](http://docs.celeryproject.org/en/latest/getting-started/first-steps-with-celery.html#application)), or you can send **vanilla AMQP messages**
that will be catched and processed by `message handlers` defined via `TASKS` environment variable. For example:

```
  $ docker run -it --rm --network=eeadockercelery_default --link=rabbit:rabbit python:2 bash
  $ pip install eea.rabbitmq.client pika==0.10.0
  $ python
```

```python
  >>> from eea.rabbitmq.client import RabbitMQConnector

  >>> rabbit_config = {
        'rabbit_host': "rabbit",
        'rabbit_port': 5672,
        'rabbit_username': "admin",
        'rabbit_password': "admin"}

  >>> rabbit = RabbitMQConnector(**rabbit_config)
  >>> rabbit.open_connection()

  >>> rabbit.declare_queue("nltk_queue")
  >>> rabbit.send_message("nltk_queue", "Hello world !!!")

  >>> rabbit.declare_queue("req_queue")
  >>> rabbit.send_message("req_queue", "http://google.com")

  >>> rabbit.close_connection()
```

See Celery logs:
```
  # docker-compose logs -f celery
```

## Failure handling

If a task fails to run, `celery-message-consumer` will **retry** it, by default for **4 times** with an increasing TTL. First retry it after `200 ms`, then `1s`, then `1m`, then every `30m`. You can change this behaviour via `EVENT_CONSUMER_BACKOFF_FUNC` environment variable or change the maximum retries with `EVENT_CONSUMER_MAX_RETRIES` environment variable. See [celery-message-consumer docs](https://pypi.org/project/celery-message-consumer/) for more configuration environment variables.

If the task still fails after the max-retries, it is move to `queue.archived` and kept there by default for `24 days` after which the exchange will delete it. This gives opportunity for someone to manually retry the archived messages, perhaps after a code fix has been deployed. To change the number of days to keep failed jobs, use `EVENT_CONSUMER_ARCHIVE_EXPIRY` environment variable in `miliseconds` (e.g.: keep them for one year `EVENT_CONSUMER_ARCHIVE_EXPIRY=31536000000`)


## Supported environment variables ##

Celery can be configured by modifying the following env variables, either when running the container or in a `docker-compose.yml` file.

  * `CELERY_BROKER_URL` - Celery RabbitMQ broker URL - default `amqp://guest@rabbit`
  * `CELERY_BACKEND_URL` - Celery backend URL - default `redis://redis`
  * `REQUIREMENTS` - Python pip's `requirements.txt`
  * `CONSTRAINTS` - Python pip's `constraints.txt`
  * `TASKS` - Celery worker's `tasks.py`
  * `EVENT_CONSUMER_` - **celery-message-consumer** specific environment variables.
    * `EVENT_CONSUMER_MAX_RETRIES` defaults to 4 (i.e. 1 attempt + 4 retries = 5 strikes)
    * `EVENT_CONSUMER_ARCHIVE_EXPIRY` time in milliseconds to keep messages in the “archive” queue, after which the exchange will delete them. - default to `24 days`.
    * [See more](https://pypi.org/project/celery-message-consumer)


## Copyright and license

The Initial Owner of the Original Code is European Environment Agency (EEA).
All Rights Reserved.

The Original Code is free software;
you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later
version.


## Funding

[European Environment Agency (EU)](http://eea.europa.eu)
