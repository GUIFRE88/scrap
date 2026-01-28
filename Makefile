SHELL := /usr/bin/bash

.PHONY: start stop bash logs clean restart build

build:
	docker-compose build

start:
	docker-compose run --service-ports web bin/rails server -b 0.0.0.0

start-detached:
	docker-compose up -d --build

stop:
	docker-compose down

clean:
	docker-compose down -v
	docker-compose rm -f

restart: clean start

bash:
	docker-compose exec web bash

logs:
	docker-compose logs -f web

