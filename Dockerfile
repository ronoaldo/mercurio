FROM ghcr.io/ronoaldo/luantiserver:5.10.0

# Setup system-wide settings
USER root
RUN mkdir -p /var/lib/luanti &&\
    mkdir -p /var/lib/luanti/.minetest &&\
    chown -R luanti /var/lib/luanti /var/lib/luanti /etc/luanti

# Install additional tools for the server
RUN apt-get update && apt-get install jq curl -yq && apt-get clean

# Install mods system-wide (ro)
COPY mods           /usr/share/luanti/mods
# Add server skins to database
COPY skins/meta     /usr/share/luanti/mods/skinsdb/meta
COPY skins/textures /usr/share/luanti/mods/skinsdb/textures
# Add server mod
COPY mercurio       /usr/share/luanti/mods/mercurio

# Add configuration files to image
COPY world.mt            /etc/luanti/world.mt
COPY luanti.conf         /etc/luanti/luanti.conf
COPY news                /etc/luanti/news
COPY scripts/mercurio.sh /usr/bin
COPY scripts/backup.sh   /usr/bin
COPY scripts/lib         /usr/lib/scripts

# Force load screwdriver mod as it is used by many ones
# After Minetest 5.9 several mods stopped loading properly
RUN echo "first_mod=screwdriver" >> /usr/share/luanti/games/minetest_game/game.conf

# Restore user to minetest and redefine launch script
WORKDIR /var/lib/luanti
USER luanti
CMD ["/usr/bin/mercurio.sh"]
