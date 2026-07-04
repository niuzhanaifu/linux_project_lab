ROOT_DIR := $(CURDIR)
BUILDROOT_VERSION ?= 2026.02.3
BUILDROOT_DIR ?= $(ROOT_DIR)/.cache/buildroot-$(BUILDROOT_VERSION)
BUILDROOT_DL_DIR ?= $(ROOT_DIR)/.cache/dl
BUILD_DIR ?= $(ROOT_DIR)/output/qemu-aarch64
BR2_EXTERNAL ?= $(ROOT_DIR)/br2-external
LAB01_LOG ?= $(ROOT_DIR)/artifacts/lab01/serial.log
DOCKER_COMPOSE ?= docker compose
LAB_IMAGE ?= ghcr.io/niuzhanaifu/linux-project-lab:lab-v0.0.1

.PHONY: help lab01-fetch lab01-defconfig edge-agent-dirclean lab01-build lab01-run lab01-check lab01 lab01-clean edge-agent-native docker-preload-dl docker-build docker-shell docker-lab01-build docker-lab01-run docker-lab01-check docker-lab01 docker-image-build docker-image-push student-pull student-lab01-build student-lab01-run student-lab01-check student-lab01

help:
	@printf "%s\n" "Targets:"
	@printf "%s\n" "  make lab01-build       Build QEMU ARM64 Linux image with Buildroot"
	@printf "%s\n" "  make lab01-run         Boot the image with QEMU and capture serial log"
	@printf "%s\n" "  make lab01-check       Validate Lab01 serial log"
	@printf "%s\n" "  make lab01             Build, boot, and check Lab01"
	@printf "%s\n" "  make edge-agent-native Build edge-agent for the host"
	@printf "%s\n" "  make docker-preload-dl Copy .cache/dl into Docker image preload context"
	@printf "%s\n" "  make docker-lab01      Run Lab01 through Docker"
	@printf "%s\n" "  make student-lab01     Maintainer smoke test with prebuilt image"
	@printf "%s\n" "  make docker-image-push Push LAB_IMAGE to registry"
	@printf "%s\n" "  make lab01-clean       Remove Lab01 build output"

lab01-fetch:
	@if [ -d "$(BUILDROOT_DIR)" ]; then \
		echo "Buildroot already exists: $(BUILDROOT_DIR)"; \
	else \
		BUILDROOT_VERSION="$(BUILDROOT_VERSION)" bash scripts/fetch-buildroot.sh; \
	fi

lab01-defconfig: lab01-fetch
	mkdir -p "$(BUILD_DIR)"
	$(MAKE) -C "$(BUILDROOT_DIR)" O="$(BUILD_DIR)" BR2_EXTERNAL="$(BR2_EXTERNAL)" BR2_DL_DIR="$(BUILDROOT_DL_DIR)" qemu_aarch64_virt_defconfig
	cat "$(ROOT_DIR)/boards/qemu-aarch64/buildroot_fragment" >> "$(BUILD_DIR)/.config"
	$(MAKE) -C "$(BUILDROOT_DIR)" O="$(BUILD_DIR)" BR2_EXTERNAL="$(BR2_EXTERNAL)" BR2_DL_DIR="$(BUILDROOT_DL_DIR)" olddefconfig

edge-agent-dirclean: lab01-defconfig
	@if [ -d "$(BUILD_DIR)/build/edge-agent-0.1.0" ]; then \
		$(MAKE) -C "$(BUILDROOT_DIR)" O="$(BUILD_DIR)" BR2_EXTERNAL="$(BR2_EXTERNAL)" BR2_DL_DIR="$(BUILDROOT_DL_DIR)" edge-agent-dirclean; \
	else \
		echo "edge-agent build cache is clean"; \
	fi

lab01-build: edge-agent-dirclean
	$(MAKE) -C "$(BUILDROOT_DIR)" O="$(BUILD_DIR)" BR2_EXTERNAL="$(BR2_EXTERNAL)" BR2_DL_DIR="$(BUILDROOT_DL_DIR)"

lab01-run:
	BUILD_DIR="$(BUILD_DIR)" LOG_FILE="$(LAB01_LOG)" bash tests/lab01/run-qemu.sh

lab01-check:
	python3 tests/lab01/check-output.py "$(LAB01_LOG)"

lab01:
	@bash scripts/lab01.sh

edge-agent-native:
	$(MAKE) -C apps/edge-agent

lab01-clean:
	rm -rf "$(BUILD_DIR)" "$(ROOT_DIR)/artifacts/lab01"

docker-preload-dl:
	bash scripts/preload-buildroot-dl.sh

docker-build:
	$(DOCKER_COMPOSE) build lab

docker-shell: docker-build
	$(DOCKER_COMPOSE) run --rm lab bash

docker-lab01-build: docker-build
	$(DOCKER_COMPOSE) run --rm lab make lab01-build

docker-lab01-run:
	$(DOCKER_COMPOSE) run --rm lab make lab01-run

docker-lab01-check:
	$(DOCKER_COMPOSE) run --rm lab make lab01-check

docker-lab01: docker-build
	$(DOCKER_COMPOSE) run --rm lab make lab01

docker-image-build:
	docker build --build-arg BUILDROOT_VERSION="$(BUILDROOT_VERSION)" -t "$(LAB_IMAGE)" .

docker-image-push:
	docker push "$(LAB_IMAGE)"

student-pull:
	LAB_IMAGE="$(LAB_IMAGE)" $(DOCKER_COMPOSE) -f docker-compose.student.yml pull lab

student-lab01-build:
	LAB_IMAGE="$(LAB_IMAGE)" $(DOCKER_COMPOSE) -f docker-compose.student.yml run --rm lab make lab01-build

student-lab01-run:
	LAB_IMAGE="$(LAB_IMAGE)" $(DOCKER_COMPOSE) -f docker-compose.student.yml run --rm lab make lab01-run

student-lab01-check:
	LAB_IMAGE="$(LAB_IMAGE)" $(DOCKER_COMPOSE) -f docker-compose.student.yml run --rm lab make lab01-check

student-lab01: student-pull
	LAB_IMAGE="$(LAB_IMAGE)" $(DOCKER_COMPOSE) -f docker-compose.student.yml run --rm lab make lab01
