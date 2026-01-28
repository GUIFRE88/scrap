SHELL := /usr/bin/bash

.PHONY: start start-byebug stop bash bash-test logs clean restart build bundle-install rspec test-db-prepare

build:
	docker-compose build

build-no-cache:
	docker-compose build --no-cache

bundle-install:
	docker-compose exec web bundle install

start-byebug:
	docker-compose run --service-ports web bin/rails server -b 0.0.0.0

start:
	docker-compose up --build

test-db-prepare:
	docker-compose exec -e RAILS_ENV=test -e DATABASE_URL=postgres://postgres:postgres@db:5432/scrap_test web bundle exec rails db:test:prepare

rspec: test-db-prepare
	docker-compose exec -e RAILS_ENV=test -e DATABASE_URL=postgres://postgres:postgres@db:5432/scrap_test web bundle exec rspec

stop:
	docker-compose down

clean:
	docker-compose down -v
	docker-compose rm -f

restart: clean start

bash:
	docker-compose exec web bash

bash-test:
	docker-compose exec -e RAILS_ENV=test -e DATABASE_URL=postgres://postgres:postgres@db:5432/scrap_test web bash

logs:
	docker-compose logs -f web

