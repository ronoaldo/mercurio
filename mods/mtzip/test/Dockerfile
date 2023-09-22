ARG ENGINE_VERSION=5.6.1
FROM registry.gitlab.com/minetest/minetest/server:${ENGINE_VERSION}

USER root

RUN apk add --no-cache lua-dev luarocks &&\
    luarocks-5.1 install luacov &&\
    luarocks-5.1 install luacov-reporter-lcov

RUN apk add --no-cache zip git &&\
    mkdir -p /root/.minetest/worlds/world/worldmods/ &&\
    cd /root/.minetest/worlds/world/worldmods/ &&\
    git clone https://github.com/BuckarooBanzay/mtt &&\
    git clone https://github.com/appgurueu/strictest

ENTRYPOINT /entrypoint.sh