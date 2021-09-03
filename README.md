# Mercurio Minetest Server

Hosting implementation of minetest server using custom Docker images.

## Developing locally

You need to have both `docker` and `docker composer` installed and working, and
optionally you can use `make` to run the scripts more easily.

To build the images, you can use:

    make build

To test locally, you can use:

    make run

To publish to a container registry:

    make deploy