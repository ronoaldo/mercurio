FROM ghcr.io/ronoaldo/minetestserver@sha256:6d01e021a6138ebca8b8e8c27a084cca4c8f8f3d4154f4fa956adb1d627c362a

# Setup system-wide settings
USER root
RUN mkdir -p /var/lib/mercurio &&\
    mkdir -p /var/lib/minetest/.minetest &&\
    chown -R minetest /var/lib/mercurio /var/lib/minetest /etc/minetest
# Install mods system-wide (ro)
RUN mkdir -p /usr/share/minetest/mods &&\
    cd /usr/share/minetest &&\
    contentdb install --debug --url=https://contentdb.ronoaldo.net \
        apercy/kartcar@ \
        apercy/trike@9794 \
        apercy/hidroplane@9880 \
        apercy/motorboat@8453 \
        apercy/demoiselle@9812 \
        AiTechEye/smartshop@903 \
        BuckarooBanzay/mapserver@7753 \
        bell07/carpets@3671 \
        bell07/skinsdb@8299 \
        Calinou/moreblocks@8247 \
        Calinou/moreores@8248 \
        cronvel/respawn@2406 \
        Dragonop/tools_obsidian@6102 \
        Don/mydoors@222 \
        ElCeejo/draconis@9352 \
        ElCeejo/mob_core@8939 \
        FaceDeer/anvil@5696 \
        FaceDeer/hopper@6074 \
        Gundul/water_life@9651 \
        "Hybrid Dog/we_undo@9288" \
        JAstudios/moreswords@9585 \
        Jeija/digilines@8574 \
        Jeija/mesecons@9802 \
        joe7575/lumberjack@7252 \
        jp/xdecor@8625 \
        Liil/nativevillages@7404 \
        Liil/people@6771 \
        Linuxdirk/mtimer@9530 \
        Lokrates/biofuel@5970 \
        Lone_Wolf/headanim@8888 \
        MeseCraft/void_chest@5565 \
        mt-mods/travelnet@8497 \
        neko259/telegram@6870 \
        philipmi/regrowing_fruits@5746 \
        Piezo_/illumination@1091 \
        PilzAdam/nether@8686 \
        RealBadAngel/unified_inventory@9734 \
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
        stu/3d_armor@9664 \
        TenPlus1/bakedclay@9438 \
        TenPlus1/bonemeal@9389 \
        TenPlus1/dmobs@9170 \
        TenPlus1/ethereal@9788 \
        TenPlus1/farming@9879 \
        TenPlus1/itemframes@7148 \
        TenPlus1/mob_horse@9669 \
        TenPlus1/mobs@9680 \
        TenPlus1/mobs_animal@9670 \
        TenPlus1/mobs_monster@9671 \
        TenPlus1/mobs_npc@9672 \
        TenPlus1/protector@9538 \
        Termos/mobkit@6391 \
        Traxie21/tpr@8314 \
        VanessaE/basic_materials@6297 \
        VanessaE/basic_signs@7503 \
        VanessaE/currency@7512 \
        VanessaE/homedecor_modpack@7219 \
        VanessaE/home_workshop_modpack@7501 \
        VanessaE/unifieddyes@7577 \
        VanessaE/signs_lib@6803 \
        Wuzzy/calendar@5062 \
        Wuzzy/hbarmor@1275 \
        Wuzzy/hbhunger@9156 \
        Wuzzy/hudbars@8390 \
        Wuzzy/inventory_icon@469 \
        Wuzzy/show_wielded_item@7596 \
        Wuzzy/tsm_pyramids@3355 \
        x2048/cinematic@7122
# Install mods from git when not available elsewhere
RUN apt-get update && apt-get install git -yq && apt-get clean &&\
    cd /usr/share/minetest/mods &&\
    git clone --depth=1 https://github.com/ronoaldo/airutils --branch="git20211129" &&\
    git clone --depth=1 https://github.com/ronoaldo/aviator --branch="V1.6" &&\
    git clone --depth=1 https://github.com/ronoaldo/filler --branch="git20180215" &&\
    git clone --depth=1 https://github.com/ronoaldo/minenews --branch="v1.0.0" &&\
    git clone --depth=1 https://github.com/ronoaldo/patron --branch="v1.0.0" &&\
    git clone --depth=1 https://github.com/ronoaldo/extra_doors --branch="v1.0.0-mercurio" &&\
    git clone --depth=1 https://github.com/ronoaldo/x_bows --branch="v1.0.5" &&\
    git clone --depth=1 https://github.com/ronoaldo/hbsprint --branch="v1.0.0-mercurio" &&\
    git clone --depth=1 https://github.com/ronoaldo/supercub --branch="git20211207" &&\
    git clone --depth=1 https://github.com/ronoaldo/ju52 --branch="git20211207" &&\
    git clone --depth=1 https://github.com/ronoaldo/helicopter --branch="before"
# Fetch all skins from database
# TODO(ronoaldo): limit to selected skins to avoid abuse
COPY fetch-skins.sh /usr/local/bin
RUN apt-get install jq curl -yq && apt-get clean && cd /usr/share/minetest/mods/skinsdb && fetch-skins.sh
# Add server mod
COPY ./mercurio /usr/share/minetest/mods/mercurio
# Add configuration files to image
COPY world.mt      /etc/minetest/world.mt
COPY minetest.conf /etc/minetest/minetest.conf
COPY mercurio.sh   /usr/bin
COPY backup.sh     /usr/bin
# Restore user to minetest and redefine launch script
USER minetest
CMD ["/usr/bin/mercurio.sh"]
