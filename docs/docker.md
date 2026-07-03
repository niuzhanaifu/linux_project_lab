# Docker Workflow

Docker is the required student path. Students only need Docker; the container provides `make`, Buildroot host dependencies, the pinned Buildroot source tree, QEMU, and the optional preloaded Buildroot download cache.
The prebuilt image also includes the pinned Buildroot source tree under `/opt/buildroot-$BUILDROOT_VERSION`.

## Why Docker

- Keeps the teacher, CI, cloud server, and student environments consistent.
- Avoids asking students to install Buildroot dependencies one by one.
- Keeps QEMU inside the lab container.
- Keeps the pinned Buildroot source inside the lab container.
- Can preload Buildroot package downloads into the image to reduce student-side downloads.
- Reuses `.cache/` and `output/` through the mounted repository directory.

## Teacher and CI Image Build

Install Docker Engine and the Compose plugin on the server, then build and validate the lab image:

```sh
export LAB_UID=$(id -u)
export LAB_GID=$(id -g)
docker compose build lab
docker compose run --rm lab make lab01-build
docker compose run --rm lab make lab01-run
docker compose run --rm lab make lab01-check
```

The Docker image build downloads the pinned Buildroot source into `/opt`. The first teacher-side Lab01 build can still download package sources into `.cache/dl`, so it can take a while.

Before publishing, copy the populated cache into the Docker preload context and rebuild the image:

```sh
make docker-preload-dl
docker compose build lab
```

The rebuilt image stores the cache under `/opt/buildroot-dl`. When students run the container, the entrypoint copies missing files from `/opt/buildroot-dl` into the mounted repository cache at `.cache/dl`.

## Student Setup

Students should install Docker Desktop on Windows/macOS or Docker Engine on Linux. On Windows, use WSL2-backed Docker Desktop.

Then run:

```sh
docker compose -f docker-compose.student.yml pull lab
docker compose -f docker-compose.student.yml run --rm lab make lab01-build
docker compose -f docker-compose.student.yml run --rm lab make lab01-run
docker compose -f docker-compose.student.yml run --rm lab make lab01-check
```

Students do not build the Docker image locally and do not install host `make`, QEMU, Buildroot, or a cross toolchain. The `make` command runs inside the prebuilt container.

## Linux Permission Note

On Linux hosts, pass your UID/GID if generated files become root-owned:

```sh
export LAB_UID=$(id -u)
export LAB_GID=$(id -g)
docker compose -f docker-compose.student.yml run --rm lab make lab01-build
```

## Faster Course Delivery

For a paid course, publish a prebuilt image:

```sh
export LAB_IMAGE=ghcr.io/your-org/linux-edge-lab:lab01
make docker-image-build LAB_IMAGE="$LAB_IMAGE"
make docker-image-push LAB_IMAGE="$LAB_IMAGE"
```

Then students can use `docker-compose.student.yml` so they do not build the environment locally. See `docs/cloud-deploy.md`.
