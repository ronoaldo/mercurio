# Mercurio Minetest Server

Hosting implementation of minetest server using custom Docker image
for the Mercurio minetest server.

## Developing locally

You need to have both `docker` and `docker composer` installed and working, and
optionally you can use `make` to run the scripts more easily.

In order to change some settings for your local develoopment environment, copy
the `docker-compose.dev.yml` as a local override. This way you can change things
such as the server port:

    cp docker-compose.dev.yml docker-compose.override.yml

### Run a local server

To test locally, you can use:

    make run

This command will use `docker compose` to execute all the services needed,
including a local PostgreSQL database, the Discord chat bridge and the game
server itself.

To test the server, launch the minetest client and connect with `127.0.0.1`
and port `30000`.

### Local data storage

The containers will store data in a `.minetest` folder in the current directory.
The game data will be in `.minetest/world`, and the database files are under
`.minetest/db`.

To make a backup you can use the following make target:

    make backup

Backups will be stored in `$HOME/backups/`.

### Container shell

Sometimes you may want to open a shell interpreter inside the running container,
in order to check if all things are right. There is a make target for that as well:

    make shell

This will open a shell with `root` privileges so you can debug the game server.
It is required that you have the server running in the background (i.e. you need
to have it running from `make run` first).

### Troubheshooting

Sometimes you may run into permission issues. I'm not sure why/how to fix
them permanently, but I have made a small shell script to fix them as a
workaround:

    make fix-perms

This one requires your login shell to have `sudo` privileges.

## Install and update mods

For this server, we are using a local copy of the released mods from ContentDB
whenever possible, plus a few set of Git submodules when some special patch is
needed or when the mod is not published to the central repository.

The reason to use ContentDB is mostly because a) I'm using specific versions of
the mods, that are released by the mod authors and intended to be used by the
public and b) there is a team of people that curates the published mods to make
sure they abide for the [documented policies](https://content.minetest.net/policy_and_guidance/).

If mods are available from ContentDB, one can use the command line tool `contentdb`
that I have developed to both add a new mod or to update existing ones. Please
check the installation instructions here: https://github.com/ronoaldo/minetools#install-pre-compiled-binaries-on-linux.

### Installing a new mod from ContentDB

It is as simple as running the `contentdb install` command. For instance, to install
the mod PA 28 from APercy, available at content.minetest.net/packages/**apercy/pa28**, use:

    contentdb install apercy/pa28

The syntax is basically `author/modname` from the ContentDB API (same used in
the browser URL). The command **must be executed from the root folder of the project**.

### Update mods from ContentDB

Similar to the [Installing a new mod from ContentDB](#installing-a-new-mod-from-contentdb)
part, the tool can be used to update a mod:

    contentdb install --update apercy/pa28

There is a convenience command in the tool that can be used to **update all at
once**:

    contentdb update
