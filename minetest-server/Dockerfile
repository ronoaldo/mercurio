# Build stage
FROM debian:bullseye AS builder

# Install all build-dependencies
ARG VERSION=5.4.1
RUN apt-get update &&\
    apt-get install build-essential cmake gettext libbz2-dev libcurl4-gnutls-dev \
        libfreetype6-dev libglu1-mesa-dev libgmp-dev libirrlicht-dev \
        libjpeg-dev libjsoncpp-dev libleveldb-dev libluajit-5.1-dev \
        libogg-dev libopenal-dev libpng-dev libpq-dev libspatialindex-dev \
        libsqlite3-dev libvorbis-dev libx11-dev libxxf86vm-dev \
        postgresql-server-dev-all zlib1g-dev curl -yq &&\
    apt-get clean

# Fetch source
RUN mkdir -p /usr/src &&\
    curl -SsL --fail \
        https://github.com/ronoaldo/minetest/archive/refs/tags/$VERSION.tar.gz > /tmp/minetest.tar.gz &&\
    cd /tmp/ && tar xf minetest.tar.gz && mv minetest-$VERSION /usr/src/minetest &&\
    rm /tmp/minetest.tar.gz

# Build server
WORKDIR /tmp/build
RUN cmake /usr/src/minetest \
        -DENABLE_POSTGRESQL=TRUE \
        -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SERVER=TRUE \
        -DBUILD_CLIENT=FALSE \
        -DBUILD_UNITTESTS=FALSE &&\
    make -j$(nproc) &&\
    make install

# Install MTG
RUN curl -SsL --fail \
        https://github.com/ronoaldo/minetest_game/archive/refs/tags/$VERSION.tar.gz > /tmp/minetest_game.tar.gz &&\
    cd /tmp/ && tar xf minetest_game.tar.gz && mv minetest_game-$VERSION /usr/share/minetest/games/minetest_game &&\
    rm /tmp/minetest_game.tar.gz

# Bundle only the runtime dependencies
FROM debian:bullseye AS runtime
RUN apt-get update &&\
    apt-get install libcurl3-gnutls libgcc-s1 libgmp10 libjsoncpp24 \
        libleveldb1d liblua5.1-0 libluajit-5.1-2 libncursesw6 libpq5 \
        libspatialindex6 libsqlite3-0 libstdc++6 libtinfo6 zlib1g \
        adduser unzip curl -yq &&\
    apt-get clean
RUN adduser --system --uid 30000 --home /var/lib/minetest minetest &&\
    chown -R minetest /var/lib/minetest

# Install contentdb CLI
RUN curl -SsL --fail \
        https://github.com/ronoaldo/minetools/releases/download/v0.1.4/contentdb-linux-amd64.zip > /tmp/minetools.zip &&\
        cd /tmp/ && unzip minetools.zip && mv dist/contentdb /usr/bin &&\
        rm /tmp/minetools.zip

# Copy files and folders
COPY --from=builder /usr/share/minetest /usr/share/minetest
COPY --from=builder /usr/bin/minetestserver /usr/bin
COPY --from=builder /usr/share/doc/minetest/minetest.conf.example /etc/minetest/minetest.conf
ADD minetest-wrapper.sh /usr/bin

WORKDIR /var/lib/minetest
USER minetest
EXPOSE 30000/udp 30000/tcp
CMD ["/usr/bin/minetest-wrapper.sh", "--config", "/etc/minetest/minetest.conf"]
