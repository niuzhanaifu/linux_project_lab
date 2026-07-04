# Lab01: Boot Your First Embedded Linux System

## Goal

Build an ARM64 Linux image, boot it with QEMU, and prove that a custom user-space program runs automatically during system startup.

## What You Will Change

Edit `apps/edge-agent/main.c`:

```c
#define EDGE_DEVICE_ID "student_demo"
```

Change it to your own ID:

```c
#define EDGE_DEVICE_ID "student_20260001"
```

The value must start with `student_` and only use lowercase letters, digits, `_`, or `-`.

## Local Commands

```sh
docker compose -f docker-compose.student.yml pull lab
docker compose -f docker-compose.student.yml run --rm lab make lab01
```

The host only needs Docker. `make`, Buildroot, and QEMU run inside the lab container.

Expected final result:

```text
LAB01 PASS
```

## Grading Rules

- 40%: Buildroot image builds successfully.
- 30%: QEMU boots to user space.
- 20%: `edge-agent` starts automatically.
- 10%: `device_id` matches the required format.

## Debug Tips

Check the serial log:

```sh
cat artifacts/lab01/serial.log
```

If QEMU is missing, you are probably running the lab outside the student container or using an outdated image. Pull the student image again:

```sh
docker compose -f docker-compose.student.yml pull lab
```
