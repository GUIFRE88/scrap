SHELL := /usr/bin/bash

.PHONY: start start-byebug stop bash bash-test logs clean restart build bundle-install rspec

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

rspec:
	docker-compose exec -T -e RAILS_ENV=test -e DATABASE_URL=postgres://postgres:postgres@db:5432/scrap_test web bash -c "bundle exec rails db:test:prepare && bundle exec rspec spec"

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

