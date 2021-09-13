MERCURIO_VERSION=2.0.3mt5.4.1
MERCURIO_IMAGE=ghcr.io/ronoaldo/mercurio
MERCURIO_SERVER=$(MERCURIO_IMAGE):$(MERCURIO_VERSION)

run: build
	#sudo chown -R 30000:$(id -g) .minetest/world
	docker-compose up

build:
	docker build --tag $(MERCURIO_SERVER) .
	docker tag $(MERCURIO_SERVER) $(MERCURIO_IMAGE):latest

deploy:
	docker push $(MERCURIO_SERVER)
	docker push $(MERCURIO_IMAGE):latest

fix-perms:
	sudo chown -R 30000:$$(id -g) .minetest/world
	sudo chmod -R g+w .minetest/world