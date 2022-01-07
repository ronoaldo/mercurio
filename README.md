# Mercurio Minetest Server

Hosting implementation of minetest server using custom Docker image
for the Mercurio minetest server.

## Developing locally

You need to have both `docker` and `docker composer` installed and working, and
optionally you can use `make` to run the scripts more easily.

In order to change some settings, copy the docker-compose.dev.yml as a local
override:

    cp docker-compose.dev.yml docker-compose.override.yml

### Run a local server

To test locally, you can use:

    make run-interactive

This command will use `docker compose` to execute all the services needed,
including a local PostgreSQL database, the Mapserver backend and the game
server itself.

To test the server, launch the minetest client and connect with `127.0.0.1`
and port `30000`.

### Local data storage

The containers will store data in a `.minetest` folder in the current directory.
The game data will be in `.minetest/world`, and the database files are under
`.minetest/db`.

To make a backup you can use the following make target:

    make backup

Backups will be stored in $HOME/backups/

### Container shell

Sometimes you may want to open a shell interpreter inside the running container,
in order to check if all things are right. There is a make target for that as well:

    make shell

This will open a shell with `root` privileges so you can debug the game server.

### Running with Podman (Experimental)

Podman can be used for development instead of Docker, but this is currently
experimental. To get started, make sure you have a recent version of Podman and
use the files env-configmap.dev.yaml and mercurio.yaml to launch the server.

A make target is also available:

    make run-with-podman

### Troubheshooting

Sometimes you may run into permission issues. I'm not sure why/how to fix
them permanently, but I have made a small shell script to fix them as a
workaround:

    make fix-perms

This one requires your login shell to have `sudo` privileges.

## Updating mods

For this implementation, I'm considering both game files as well as mod code
to be part of the "game codebase". Thus, as much as possible, mods are *pinned*
to specific versions.

In order to check for updates, you can use the `contentdb` program inside the
container either manually via the `make shell` program, or using the convenient
target:

    make check-mod-updates

The output will print all mods with newer versions on Contentdb, and which Git
mods can be updated.