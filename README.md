# Embedded Linux Edge Lab

这是一个面向 MCU 基础学习者的嵌入式 Linux 项目制实验仓库。课程目标不是完成零散实验，而是逐步构建一个可以写进简历、可以在面试中讲清楚的嵌入式 Linux 边缘设备项目。

当前主线从 `Lab01` 开始：在 Docker 容器里使用 Buildroot 构建 ARM64 Linux 镜像，用 QEMU 启动系统，并在启动过程中运行 `edge-agent`。

## 学生环境要求

学生电脑只需要准备 Docker：

- Windows/macOS：安装 Docker Desktop。
- Linux：安装 Docker Engine 和 Docker Compose 插件。

学生不需要在宿主机安装 `make`、Buildroot 源码、交叉编译工具链或 QEMU。课程发布的预构建 Docker 镜像已经包含这些内容，仓库只保存实验代码、配置和文档。

## Repository Layout

```text
apps/edge-agent/          # 最终项目的用户态守护进程雏形
boards/qemu-aarch64/      # QEMU virt 平台配置
boards/rk3568/            # RK3568 后续板级适配入口
br2-external/             # Buildroot external tree
docs/                     # 环境、路线图、实验说明
tests/lab01/              # QEMU 启动和自动验收脚本
.github/workflows/        # CI 自动构建和验收
```

## Quick Start

首次拉取仓库后运行：

```sh
git clone <your-repo-url> linux-edge-lab
cd linux-edge-lab
docker compose -f docker-compose.student.yml pull lab
docker compose -f docker-compose.student.yml run --rm lab make lab01
```

后续实验同步仓库即可：

```sh
git pull
docker compose -f docker-compose.student.yml pull lab
```

命令里的 `make` 在 Docker 容器内部执行，不要求学生在宿主机安装 `make`。

Docker 细节见 `docs/docker.md`。

教师发布镜像和学生使用流程见 `docs/cloud-deploy.md`。

## Current Lab Goal

`Lab01` 要求学员修改 `apps/edge-agent/main.c` 中的 `EDGE_DEVICE_ID`，提交后由 CI 检查：

- Buildroot 镜像是否能构建；
- QEMU 是否能启动到用户空间；
- `edge-agent` 是否自动运行；
- `device_id` 是否符合 `student_xxx` 格式。

后续实验会在这个项目上增加字符设备驱动、设备树、RK3568 BSP、日志框架、互联互通、OTA、快启和低功耗优化。
