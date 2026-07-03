# Course Roadmap

## Phase 1: Reproducible Linux System

- Lab01: Buildroot + QEMU boot + `edge-agent` auto-start.
- Lab02: Linux process, filesystem, init script, and rootfs layout.
- Lab03: kernel module and character device skeleton.
- Lab04: platform driver and device tree on QEMU.

## Phase 2: RK3568 BSP

- Lab05: serial console, flashing, boot log, and recovery path.
- Lab06: U-Boot environment, kernel, DTB, and rootfs loading.
- Lab07: GPIO/PWM/I2C/UART device tree changes.
- Lab08: migrate `edge-agent` hardware adapter from QEMU to RK3568.

## Phase 3: Interview-Ready Project

- Lab09: structured logging, config, health check, and watchdog.
- Lab10: MQTT or HTTP device connectivity.
- Lab11: OTA package, signature check, A/B update, rollback test.
- Lab12: boot-time analysis and fast boot optimization.
- Lab13: low-power states, wakeup source, and runtime PM validation.

## Final Deliverable

Students finish with one repository that contains source code, board notes, CI logs, test reports, and an architecture document they can explain in an interview.

