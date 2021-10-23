run: 
	docker-compose down && docker-compose up --build --detach

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
	docker-compose exec --user 0 game bash -c 'cd /usr/share/minetest && contentdb update --dry-run' | tee /tmp/updates.log

fix-perms:
	sudo chown -R 30000:$$(id -g) .minetest/world
	sudo chmod -R g+w .minetest/world
	sudo find .minetest/world -type d -exec chmod g+rwx {} ';'
	sudo chgrp $$(id -g) .minetest
	sudo chmod g+rwx .minetest
