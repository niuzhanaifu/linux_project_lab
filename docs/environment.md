# Environment Setup

## Student Environment

Students only need Docker on the host:

- Windows/macOS: Docker Desktop.
- Linux: Docker Engine plus the Docker Compose plugin.

Do not install host `make`, Buildroot source, a cross toolchain, or QEMU for the course labs. Those tools live in the published Docker image.

After cloning or updating the repository, run the student Compose file:

```sh
docker compose -f docker-compose.student.yml pull lab
docker compose -f docker-compose.student.yml run --rm lab make lab01-build
docker compose -f docker-compose.student.yml run --rm lab make lab01-run
docker compose -f docker-compose.student.yml run --rm lab make lab01-check
```

The `make` command above runs inside the container. The host only runs Docker.

## Updating Labs

When a new lab is released, sync the repository and pull the matching image:

```sh
git pull
docker compose -f docker-compose.student.yml pull lab
```

## Maintainer Native Tools

The native Linux dependency path is for maintainers only. It is useful when developing the Docker image or debugging CI, but it is not part of the student setup.

Maintainers can build the environment image with:

```sh
docker compose build lab
```

## Windows Notes

Docker Desktop should use the WSL2 backend. The student workflow still runs through Docker Compose, not through a manually prepared WSL toolchain.

If using Git inside WSL2, keep the repository under the Linux filesystem, for example:

```text
~/work/linux-edge-lab
```
