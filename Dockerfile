FROM ghcr.io/ronoaldo/minetestserver:stable-5

# Setup system-wide settings
USER root
RUN mkdir -p /var/lib/mercurio &&\
    mkdir -p /var/lib/minetest/.minetest &&\
    chown -R minetest /var/lib/mercurio /var/lib/minetest /etc/minetest
# Install mods system-wide (ro)
RUN mkdir -p /usr/share/minetest/mods &&\
    cd /usr/share/minetest &&\
    contentdb install \
        apercy/trike \
        apercy/hidroplane \
        apercy/motorboat \
        apercy/demoiselle \
        AiTechEye/smartshop \
        bell07/carpets \
        bell07/skinsdb \
        Calinou/moreblocks \
        Calinou/moreores \
        cronvel/respawn \
        Dragonop/tools_obsidian \
        Don/mydoors \
        ElCeejo/draconis \
        ElCeejo/mob_core \
        ElCeejo/loot_crates \
        FaceDeer/anvil \
        FaceDeer/hopper \
        Gundul/water_life \
        JAstudios/moreswords \
        Jeija/digilines \
        Jeija/mesecons \
        joe7575/lumberjack \
        jp/xdecor \
        Liil/nativevillages \
        Liil/people \
        Linuxdirk/mtimer \
        Lokrates/biofuel \
        Lone_Wolf/headanim \
        MeseCraft/void_chest \
        mt-mods/travelnet \
        neko259/telegram \
        philipmi/regrowing_fruits \
        Piezo_/illumination \
        PilzAdam/nether \
        RealBadAngel/unified_inventory \
        rnd/basic_machines \
        rubenwardy/awards \
        ShadowNinja/areas \
        Shara/abriglass \
        sofar/crops \
        sofar/emote \
        Sokomine/markers \
        Sokomine/replacer \
        stu/3d_armor \
        TenPlus1/bonemeal \
        TenPlus1/dmobs \
        TenPlus1/ethereal \
        TenPlus1/farming \
        TenPlus1/itemframes \
        TenPlus1/mob_horse \
        TenPlus1/mobs \
        TenPlus1/mobs_animal \
        TenPlus1/mobs_monster \
        TenPlus1/mobs_npc \
        TenPlus1/protector \
        Termos/mobkit \
        Traxie21/tpr \
        VanessaE/basic_materials \
        VanessaE/basic_signs \
        VanessaE/currency \
        VanessaE/homedecor_modpack \
        VanessaE/home_workshop_modpack \
        VanessaE/unifieddyes \
        VanessaE/signs_lib \
        Wuzzy/calendar \
        Wuzzy/hbarmor \
        Wuzzy/hbhunger \
        Wuzzy/hudbars \
        Wuzzy/inventory_icon \
        Wuzzy/show_wielded_item \
        Wuzzy/treasurer \
        Wuzzy/tsm_pyramids \
        Wuzzy/tsm_surprise \
        x2048/cinematic
# Install mods from git when not available elsewhere
RUN apt-get update && apt-get install git -yq && apt-get clean &&\
    cd /usr/share/minetest/mods &&\
    git clone --depth=1 https://github.com/APercy/airutils &&\
    git clone --depth=1 https://github.com/APercy/helicopter &&\
    git clone --depth=1 https://github.com/berengma/aviator &&\
    git clone --depth=1 https://github.com/cx384/filler &&\
    git clone --depth=1 https://github.com/ronoaldo/minenews &&\
    git clone --depth=1 https://github.com/ronoaldo/patron &&\
    git clone --depth=1 https://github.com/ronoaldo/extra_doors &&\
    git clone --depth=1 https://github.com/ronoaldo/minetest-nether-monsters nether_mobs &&\
    git clone --depth=1 https://github.com/minetest-mapserver/mapserver_mod &&\
    git clone --depth=1 https://github.com/ronoaldo/x_bows &&\
    git clone --depth=1 https://github.com/ronoaldo/hbsprint
# Fetch all skins from database
# TODO(ronoaldo): limit to selected skins to avoid abuse
ADD fetch-skins.sh /usr/local/bin
RUN apt-get install jq curl -yq && apt-get clean && cd /usr/share/minetest/mods/skinsdb && fetch-skins.sh
# Add server mod
ADD ./mercurio /usr/share/minetest/mods/mercurio
# Add configuration files to image
ADD world.mt      /etc/minetest/world.mt
ADD minetest.conf /etc/minetest/minetest.conf
ADD mercurio.sh   /usr/bin
ADD backup.sh     /usr/bin
# Restore user to minetest and redefine launch script
USER minetest
CMD ["/usr/bin/mercurio.sh"]
