FROM ghcr.io/ronoaldo/minetestserver:5.6.1

# Setup system-wide settings
USER root
RUN mkdir -p /var/lib/mercurio &&\
    mkdir -p /var/lib/minetest/.minetest &&\
    chown -R minetest /var/lib/mercurio /var/lib/minetest /etc/minetest
# Install mods system-wide (ro)
WORKDIR /usr/share/minetest
RUN contentdb install --debug \
    apercy/airutils@12849 \
    apercy/automobiles_pck@14143 \
    apercy/demoiselle@13829 \
    apercy/hidroplane@14176 \
    apercy/ju52@13762 \
    apercy/kartcar@13842 \
    apercy/motorboat@12792 \
    apercy/nautilus@11298 \
    apercy/pa28@13830 \
    apercy/supercub@13255 \
    apercy/steampunk_blimp@13095 \
    apercy/trike@13253 \
    AiTechEye/hook@1891 \
    AiTechEye/smartshop@903 \
    bell07/carpets@3671 \
    bell07/skinsdb@11695 \
    Calinou/moreblocks@13045 \
    Calinou/moreores@13155 \
    cronvel/respawn@2406 \
    Dragonop/tools_obsidian@6102 \
    Don/mydoors@13157 \
    ElCeejo/creatura@13780 \
    ElCeejo/draconis@13785 \
    FaceDeer/anvil@13166 \
    FaceDeer/hopper@12882 \
    "Hybrid Dog/we_undo@9288" \
    JAstudios/moreswords@9585 \
    Jeija/digilines@13248 \
    Jeija/mesecons@13816 \
    joe7575/lumberjack@11039 \
    joe7575/tubelib2@12793 \
    jp/xdecor@13983 \
    Just_Visiting/markdown2formspec@11639 \
    Liil/nativevillages@7404 \
    Liil/people@6771 \
    Linuxdirk/mtimer@13201 \
    Lokrates/biofuel@12552 \
    Lone_Wolf/headanim@8888 \
    MeseCraft/void_chest@12862 \
    mt-mods/travelnet@8497 \
    philipmi/regrowing_fruits@11665 \
    Piezo_/illumination@1091 \
    Piezo_/hangglider@1269 \
    PilzAdam/nether@11303 \
    ronoaldo/minenews@12102 \
    RealBadAngel/unified_inventory@13891 \
    rael5/nether_mobs@6364 \
    rnd/basic_machines@58 \
    rubenwardy/awards@6092 \
    ShadowNinja/areas@5030 \
    Shara/abriglass@32 \
    sfan5/worldedit@13367 \
    sofar/crops@176 \
    sofar/emote@13167 \
    Sokomine/markers@306 \
    Sokomine/replacer@76 \
    stu/3d_armor@13753 \
    TenPlus1/bakedclay@13687 \
    TenPlus1/bonemeal@13876 \
    TenPlus1/dmobs@13567 \
    TenPlus1/ethereal@14136 \
    TenPlus1/farming@14060 \
    TenPlus1/itemframes@12838 \
    TenPlus1/mob_horse@14104 \
    TenPlus1/mobs@14135 \
    TenPlus1/mobs_animal@13899 \
    TenPlus1/mobs_monster@13462 \
    TenPlus1/mobs_npc@ \
    TenPlus1/protector@13500 \
    Termos/mobkit@6391 \
    Termos/sailing_kit@6033 \
    Traxie21/tpr@13153 \
    VanessaE/basic_materials@13187 \
    VanessaE/basic_signs@12541 \
    VanessaE/currency@13120 \
    VanessaE/homedecor_modpack@13683 \
    VanessaE/home_workshop_modpack@12937 \
    VanessaE/unifieddyes@13815 \
    VanessaE/signs_lib@12884 \
    Wuzzy/calendar@14049 \
    Wuzzy/hbarmor@12993 \
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
    git clone --depth=1 https://github.com/ronoaldo/water_life --branch="v1.01-mercurio1"
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
