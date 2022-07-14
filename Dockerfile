# Pinned ghcr.io/ronoaldo/minetestserver:stable-5 release
FROM ghcr.io/ronoaldo/minetestserver:stable-5

# Setup system-wide settings
USER root
RUN mkdir -p /var/lib/mercurio &&\
    mkdir -p /var/lib/minetest/.minetest &&\
    chown -R minetest /var/lib/mercurio /var/lib/minetest /etc/minetest
# Install mods system-wide (ro)
WORKDIR /usr/share/minetest
RUN contentdb install --debug --url=https://contentdb.ronoaldo.net \
    apercy/airutils@12779 \
    apercy/automobiles_pck@12778 \
    apercy/demoiselle@12716 \
    apercy/hidroplane@12718 \
    apercy/ju52@12719 \
    apercy/kartcar@12788 \
    apercy/motorboat@12792 \
    apercy/nautilus@11298 \
    apercy/supercub@12717 \
    apercy/trike@12720 \
    AiTechEye/hook@1891 \
    AiTechEye/smartshop@903 \
    bell07/carpets@3671 \
    bell07/skinsdb@11695 \
    Calinou/moreblocks@8247 \
    Calinou/moreores@8248 \
    cronvel/respawn@2406 \
    Dragonop/tools_obsidian@6102 \
    Don/mydoors@222 \
    ElCeejo/creatura@12540 \
    ElCeejo/draconis@11787 \
    FaceDeer/anvil@5696 \
    FaceDeer/hopper@6074 \
    Gundul/water_life@12786 \
    "Hybrid Dog/we_undo@9288" \
    JAstudios/moreswords@9585 \
    Jeija/digilines@8574 \
    Jeija/mesecons@12542 \
    joe7575/lumberjack@11039 \
    joe7575/tubelib2@12793 \
    jp/xdecor@11439 \
    Just_Visiting/markdown2formspec@11639 \
    Liil/nativevillages@7404 \
    Liil/people@6771 \
    Linuxdirk/mtimer@9958 \
    Lokrates/biofuel@12552 \
    Lone_Wolf/headanim@8888 \
    MeseCraft/void_chest@5565 \
    mt-mods/travelnet@8497 \
    philipmi/regrowing_fruits@11665 \
    Piezo_/illumination@1091 \
    Piezo_/hangglider@1269 \
    PilzAdam/nether@11303 \
    ronoaldo/minenews@12102 \
    RealBadAngel/unified_inventory@11942 \
    rael5/nether_mobs@6364 \
    rnd/basic_machines@58 \
    rubenwardy/awards@6092 \
    ShadowNinja/areas@5030 \
    Shara/abriglass@32 \
    sfan5/worldedit@9572 \
    sofar/crops@176 \
    sofar/emote@1317 \
    Sokomine/markers@306 \
    Sokomine/replacer@76 \
    stu/3d_armor@11723 \
    TenPlus1/bakedclay@9438 \
    TenPlus1/bonemeal@12754 \
    TenPlus1/dmobs@11568 \
    TenPlus1/ethereal@12755 \
    TenPlus1/farming@12615 \
    TenPlus1/itemframes@10483 \
    TenPlus1/mob_horse@11324 \
    TenPlus1/mobs@12801 \
    TenPlus1/mobs_animal@12783 \
    TenPlus1/mobs_monster@12803 \
    TenPlus1/mobs_npc@12477 \
    TenPlus1/protector@11445 \
    Termos/mobkit@6391 \
    Termos/sailing_kit@6033 \
    Traxie21/tpr@8314 \
    VanessaE/basic_materials@11672 \
    VanessaE/basic_signs@12541 \
    VanessaE/currency@10265 \
    VanessaE/homedecor_modpack@12610 \
    VanessaE/home_workshop_modpack@12664 \
    VanessaE/unifieddyes@12422 \
    VanessaE/signs_lib@12557 \
    Wuzzy/calendar@5062 \
    Wuzzy/hbarmor@1275 \
    Wuzzy/hbhunger@9156 \
    Wuzzy/hudbars@8390 \
    Wuzzy/inventory_icon@469 \
    Wuzzy/show_wielded_item@7596 \
    Wuzzy/tsm_pyramids@11352 \
    x2048/cinematic@7122
# Install mods from git when not available elsewhere
RUN git config --global advice.detachedHead false &&\
    cd /usr/share/minetest/mods &&\
    git clone --depth=1 https://github.com/ronoaldo/aviator --branch="V1.6" &&\
    git clone --depth=1 https://github.com/ronoaldo/filler --branch="git20180215" &&\
    git clone --depth=1 https://github.com/ronoaldo/patron --branch="v1.0.0" &&\
    git clone --depth=1 https://github.com/ronoaldo/extra_doors --branch="v1.0.0-mercurio" &&\
    git clone --depth=1 https://github.com/ronoaldo/x_bows --branch="v1.0.5" &&\
    git clone --depth=1 https://github.com/ronoaldo/hbsprint --branch="v1.0.0-mercurio" &&\
    git clone --depth=1 https://github.com/ronoaldo/helicopter --branch="before" &&\
    git clone --depth=1 https://github.com/ronoaldo/techpack --branch="v2.06-mercurio" &&\
    git clone --depth=1 https://github.com/ronoaldo/drawers --branch="v0.6.5-mercurio1" &&\
    git clone --depth=1 https://github.com/ronoaldo/xtraores --branch="v0.22-mercurio4" &&\
    git clone --depth=1 https://github.com/ronoaldo/discordmt --branch="v0.2+mercurio1" &&\
    git clone --depth=2 https://github.com/ronoaldo/mtinfo --branch="v1-mercurio1" &&\
    git clone --depth=1 https://github.com/ronoaldo/minetest-monitoring --branch="v1.04-mercurio1" monitoring
# Install additional tools for the server
RUN apt-get update && apt-get install jq curl -yq && apt-get clean

# Add server skins to database
COPY skins/meta     /usr/share/minetest/mods/skinsdb/meta
COPY skins/textures /usr/share/minetest/mods/skinsdb/textures
# Add server mod
COPY ./mercurio /usr/share/minetest/mods/mercurio
# Add configuration files to image
COPY world.mt      /etc/minetest/world.mt
COPY minetest.conf /etc/minetest/minetest.conf
COPY news          /etc/minetest/news
COPY mercurio.sh   /usr/bin
COPY backup.sh     /usr/bin
COPY scripts/lib   /usr/lib/scripts
# Restore user to minetest and redefine launch script
WORKDIR /var/lib/minetest
USER minetest
CMD ["/usr/bin/mercurio.sh"]
