build:
	docker-compose build

TEST_ARGS=--env-file /tmp/.env.test -f docker-compose.yml -f docker-compose.test.yml
TEST_ENV= -e MERCURIO_MTINFO_AUTOSHUTDOWN=true -e NO_LOOP=true

.minetest/world:
	mkdir -p .minetest/world
	chmod a+wx .minetest/world

.minetest/logs:
	mkdir -p .minetest/logs
	chmod a+wx .minetest/logs

volumes: .minetest/world .minetest/logs

test: volumes
	docker-compose down
	sed -e 's/AUTOSHUTDOWN=.*/AUTOSHUTDOWN=true/g' .env.sample > /tmp/.env.test
	docker-compose $(TEST_ARGS) run -d db && sleep 5
	docker-compose $(TEST_ARGS) run --user 0 -T game \
		bash -c 'chown -R minetest:minetest /var/lib/mercurio'
	docker-compose $(TEST_ARGS) run $(TEST_ENV) game
	docker-compose $(TEST_ARGS) run --user 0 -T game \
		bash -c 'cd /usr/share/minetest && tar -czf - mods/' > /tmp/mods.tar.gz
	docker-compose down


run: volumes
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
	docker pull ghcr.io/ronoaldo/mercurio:main
	docker-compose pull
	docker-compose up -d

check-mod-updates:
	docker-compose exec --user 0 game bash -c \
		'cd /usr/share/minetest && contentdb update --dry-run' |\
		sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" |\
		tee /tmp/updates.log

list-mod-updates: /tmp/updates.log
	@grep updating /tmp/updates.log |\
		awk '{print $$11}' | tr -d : | tr '@' ' ' | sort -V |\
		while read m v ; do echo "$${m}@$${v}" ; done

apply-mod-updates: /tmp/updates.log
	grep updating /tmp/updates.log |\
		awk '{print $$11}' | tr -d : | tr '@' ' ' |\
		while read m v ; do echo "$${m} => $${v}" ; \
			sed -e "s,$${m}@[0-9]\+,$${m}@$${v},g" -i Dockerfile ;\
		done

extract-server-mods:
	docker-compose exec --user 0 -T game bash -c \
		'cd /usr/share/minetest && tar -czf - mods/' > /tmp/mods.tar.gz

fix-perms:
	sudo chown -R 30000:$$(id -g) .minetest/world .minetest/logs
	sudo chmod -R g+w .minetest/world
	sudo find .minetest/world -type d -exec chmod g+rwx {} ';'
	sudo chgrp $$(id -g) .minetest
	sudo chmod g+rwx .minetest
