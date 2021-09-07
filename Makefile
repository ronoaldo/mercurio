MT_VERSION=5.4.1
MT_IMAGE=ronoaldo/minetestserver
MT_SERVER=$(MT_IMAGE):$(MT_VERSION)

MERCURIO_VERSION=2.0mt5.4.1
MERCURIO_IMAGE=ronoaldo/mercurio
MERCURIO_SERVER=$(MERCURIO_IMAGE):$(MERCURIO_VERSION)

run: build
	docker-compose up

build-mt:
	docker build --tag $(MT_SERVER) ./minetest-server
	docker tag $(MT_SERVER) $(MT_IMAGE):latest

deploy-mt:
	docker push $(MT_SERVER)
	docker push $(MT_IMAGE):latest

build: build-mt
	docker build --tag $(MERCURIO_SERVER) ./mercurio-server
	docker tag $(MERCURIO_SERVER) $(MERCURIO_IMAGE):latest

deploy: deploy-mt
	docker push $(MERCURIO_SERVER)
	docker push $(MERCURIO_IMAGE):latest