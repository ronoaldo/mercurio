FROM ghcr.io/ronoaldo/minetestserver:5.7.0

# Setup system-wide settings
USER root
RUN mkdir -p /var/lib/mercurio &&\
    mkdir -p /var/lib/minetest/.minetest &&\
    chown -R minetest /var/lib/mercurio /var/lib/minetest /etc/minetest

# Install additional tools for the server
RUN apt-get update && apt-get install jq curl -yq && apt-get clean

# Install mods system-wide (ro)
COPY mods           /usr/share/minetest/mods
# Add server skins to database
COPY skins/meta     /usr/share/minetest/mods/skinsdb/meta
COPY skins/textures /usr/share/minetest/mods/skinsdb/textures
# Add server mod
COPY mercurio       /usr/share/minetest/mods/mercurio

# Add configuration files to image
COPY world.mt            /etc/minetest/world.mt
COPY minetest.conf       /etc/minetest/minetest.conf
COPY news                /etc/minetest/news
COPY scripts/mercurio.sh /usr/bin
COPY scripts/backup.sh   /usr/bin
COPY scripts/lib         /usr/lib/scripts

# Restore user to minetest and redefine launch script
WORKDIR /var/lib/minetest
USER minetest
CMD ["/usr/bin/mercurio.sh"]
