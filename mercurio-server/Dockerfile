FROM ronoaldo/minetestserver:5.4.1

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
        AiTechEye/smartshop \
        bell07/carpets \
        bell07/skinsdb \
        Calinou/moreores \
        cronvel/respawn \
        Don/mydoors \
        ElCeejo/draconis \
        ElCeejo/mob_core \
        FaceDeer/anvil \
        FaceDeer/hopper \
        Gundul/water_life \
        Jeija/digilines \
        Jeija/mesecons \
        joe7575/lumberjack \
        jp/xdecor \
        Linuxdirk/mtimer \
        LMD/character_anim \
        LMD/modlib \
        Lokrates/biofuel \
        Lone_Wolf/headanim \
        MeseCraft/void_chest \
        mt-mods/travelnet \
        neko259/telegram \
        Piezo_/illumination \
        PilzAdam/nether \
        rael5/nether_mobs \
        RealBadAngel/unified_inventory \
        rnd/basic_machines \
        rubenwardy/awards \
        ShadowNinja/areas \
        Shara/abriglass \
        Shara/server_news \
        sofar/crops \
        sofar/emote \
        Sokomine/markers \
        Sokomine/replacer \
        sorcerykid/extra_doors \
        stu/3d_armor \
        TenPlus1/bonemeal \
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
        Wuzzy/tsm_pyramids \
        x2048/cinematic
# Add configuration files to image
ADD world.mt      /etc/minetest/world.mt
ADD minetest.conf /etc/minetest/minetest.conf
ADD mercurio.sh   /usr/bin
# Restore user to minetest and redefine launch script
USER minetest
CMD ["/usr/bin/mercurio.sh"]