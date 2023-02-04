# Mercurio server build/management tool

INTERACTIVE=true
TEST_ARGS=--env-file /tmp/.env.test -f docker-compose.yml -f docker-compose.test.yml
TEST_ENV= -e MERCURIO_AUTO_SHUTDOWN=true -e NO_LOOP=true

all: build

build:
	docker-compose build

.minetest/world:
	mkdir -p .minetest/world
	chmod a+wx .minetest/world

.minetest/logs:
	mkdir -p .minetest/logs
	chmod a+wx .minetest/logs

volumes: .minetest/world .minetest/logs

submodules:
	git submodule init
	git submodule update

test: volumes submodules
	docker-compose down
	docker-compose build --no-cache game
	sed -e 's/AUTO_SHUTDOWN=.*/AUTO_SHUTDOWN=true/g' .env.sample > /tmp/.env.test
	docker-compose $(TEST_ARGS) run -d db && sleep 5
	docker-compose $(TEST_ARGS) run --user 0 -T game bash -c 'chown -R minetest:minetest /var/lib/mercurio /var/logs/minetest'
	docker-compose $(TEST_ARGS) run $(TEST_ENV) game
	docker-compose down

run: volumes submodules
	docker-compose down && docker-compose up --build --detach
	@echo "Server is running in background"
	if [ x"$(INTERACTIVE)" = x"true" ] ; then docker-compose logs -f ; fi

stop:
	docker-compose down || true

backup:
	./backup.sh

shell:
	docker-compose exec --user 0 game bash

update:
	git pull
	docker pull ghcr.io/ronoaldo/mercurio:main
	docker-compose pull
	docker-compose up -d

fix-perms:
	sudo chown -R 30000:$$(id -g) .minetest/world .minetest/logs
	sudo chmod -R g+w .minetest/world
	sudo find .minetest/world -type d -exec chmod g+rwx {} ';'
	sudo chgrp $$(id -g) .minetest
	sudo chmod g+rwx .minetest
