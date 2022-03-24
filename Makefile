build:
	docker-compose build

TEST_ARGS=--env-file /tmp/.env.test -f docker-compose.yml -f docker-compose.test.yml
TEST_ENV= -e MERCURIO_MTINFO_AUTOSHUTDOWN=true -e NO_WRAPPER=true

test:
	docker-compose down
	sed -e 's/AUTOSHUTDOWN=.*/AUTOSHUTDOWN=true/g' .env.sample > /tmp/.env.test
	docker-compose $(TEST_ARGS) run -d db && sleep 5
	docker-compose $(TEST_ARGS) run --user 0 -T game \
		bash -c 'chown -R minetest:minetest /var/lib/mercurio'
	docker-compose $(TEST_ARGS) run $(TEST_ENV) game
	docker-compose $(TEST_ARGS) run --user 0 -T game \
		bash -c 'cd /usr/share/minetest && tar -czf - mods/' > /tmp/mods.tar.gz
	docker-compose down

run: 
	docker-compose down && docker-compose up --build --detach
	@echo -e "\n\nServer is running in background ... showing logs\n\n"
	docker-compose logs -f

run-interactive: 
	docker-compose down && docker-compose up --build

backup:
	./backup.sh

shell:
	docker-compose exec --user 0 game bash

update:
	git pull
	docker-compose pull
	docker-compose up -d

check-mod-updates:
	docker-compose exec --user 0 game bash -c \
		'cd /usr/share/minetest && contentdb update --dry-run' |\
		sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" |\
		tee /tmp/updates.log

extract-server-mods:
	docker-compose exec --user 0 -T game bash -c \
		'cd /usr/share/minetest && tar -czf - mods/' > /tmp/mods.tar.gz

fix-perms:
	sudo chown -R 30000:$$(id -g) .minetest/world
	sudo chmod -R g+w .minetest/world
	sudo find .minetest/world -type d -exec chmod g+rwx {} ';'
	sudo chgrp $$(id -g) .minetest
	sudo chmod g+rwx .minetest
