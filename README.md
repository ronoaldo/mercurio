# Mercurio Minetest Server

Hosting implementation of minetest server using custom Docker images.

## Developing locally

You need to have both `docker` and `docker composer` installed and working, and
optionally you can use `make` to run the scripts more easily.

To test locally, you can use:

    make run

To make a backup, use:

    make backup

Backups will be stored in $HOME/backups/

To enter a debug shell, you can use:

    make shell