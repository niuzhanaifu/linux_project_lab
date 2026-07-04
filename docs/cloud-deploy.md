# 教师发布与学生使用流程

这份文档描述课程发布的完整路径：教师在云服务器上构建并发布预构建 Docker 镜像，学生只拉取仓库和 Docker 镜像，不在宿主机安装 `make`、Buildroot 源码、交叉编译工具链或 QEMU。

## 总体原则

- 教师负责构建和发布实验环境镜像。
- 学生电脑只安装 Docker。
- 学生实验命令统一通过 `docker-compose.student.yml` 运行。
- 学生不执行 `docker compose build`。
- 学生命令中的 `make` 运行在容器内部，不要求宿主机安装 `make`。

## 教师：首次发布 Lab01

### 1. 准备云服务器

建议使用 Ubuntu 云服务器，至少准备：

- 4 核 CPU；
- 8 GB 内存；
- 50 GB 以上磁盘；
- 能访问 Docker 镜像仓库和 Buildroot 相关下载源。

确认 Docker 和 Compose 插件可用：

```sh
docker --version
docker compose version
```

### 2. 拉取课程仓库

```sh
git clone <your-repo-url> linux-edge-lab
cd linux-edge-lab
```

### 3. 选择镜像地址

选择一个对学生可访问的镜像仓库。推荐同时准备正式版本 tag 和稳定别名 tag：

```sh
export IMAGE_REPO=ghcr.io/niuzhanaifu/linux-project-lab
export LAB_IMAGE_VERSION="$IMAGE_REPO:lab-v0.0.1"
export LAB_IMAGE_LATEST="$IMAGE_REPO:lab-stable"
export LOCAL_LAB_IMAGE="$LAB_IMAGE_VERSION"
```

如果以后迁移到阿里云，只需要替换 `IMAGE_REPO`：

```sh
export IMAGE_REPO=registry.cn-hangzhou.aliyuncs.com/<namespace>/linux-project-lab
export LAB_IMAGE_VERSION="$IMAGE_REPO:lab-v0.0.1"
export LAB_IMAGE_LATEST="$IMAGE_REPO:lab-stable"
export LOCAL_LAB_IMAGE="$LAB_IMAGE_VERSION"
```

正式版本 tag 方便复现，稳定别名 tag 方便课堂临时更新。仓库默认镜像建议使用正式版本 tag。

### 4. 构建教师镜像

```sh
export LAB_UID=$(id -u)
export LAB_GID=$(id -g)
docker compose build lab
```

这个镜像会包含：

- `make`；
- Buildroot 依赖工具；
- QEMU；
- `/opt/buildroot-2026.02.3` Buildroot 源码。

### 5. 在云服务器验证 Lab01

```sh
docker compose run --rm lab make lab01-build
docker compose run --rm lab make lab01-run
docker compose run --rm lab make lab01-check
```

成功时应看到类似输出：

```text
LAB01 PASS: student_demo
```

如果这一步失败，不要发布镜像。先修复仓库或 Dockerfile，再重新构建。

### 6. 把 Buildroot 下载缓存打进镜像

第一次 `lab01-build` 会把 Buildroot package 源码包下载到：

```text
.cache/dl/
```

为了让学生构建时尽量不再下载这些包，把这个缓存复制到 Docker 构建上下文，然后重新构建一次镜像：

```sh
make docker-preload-dl
docker compose build lab
```

第二次构建会复用前面的 Docker 缓存，通常只新增包含 `/opt/buildroot-dl` 的镜像层。学生运行容器时，入口脚本会把 `/opt/buildroot-dl` 同步到仓库的 `.cache/dl`，Buildroot 就可以直接使用这些源码包。

如果后续实验新增了 Buildroot package，教师需要重新运行对应实验构建，让 `.cache/dl` 补齐新包，然后再次执行：

```sh
make docker-preload-dl
docker compose build lab
```

### 7. 推送镜像

登录镜像仓库：

```sh
docker login registry.cn-hangzhou.aliyuncs.com
```

或：

```sh
docker login ghcr.io
```

推送固定版本 tag 和当前实验 tag：

```sh
docker push "$LAB_IMAGE_VERSION"
docker tag "$LAB_IMAGE_VERSION" "$LAB_IMAGE_LATEST"
docker push "$LAB_IMAGE_LATEST"
```

建议课程镜像设为公开镜像。私有镜像也可以，但每个学生都需要先执行 `docker login`。

### 8. 更新学生 Compose 默认镜像

编辑 `docker-compose.student.yml`，把默认镜像改成正式发布的镜像 tag：

```yaml
services:
  lab:
    image: "${LAB_IMAGE:-ghcr.io/niuzhanaifu/linux-project-lab:lab-v0.0.1}"
```

正常教学路径下，学生不应该手动设置 `LAB_IMAGE`。仓库里的默认值应该直接可用。

### 9. 提交并推送仓库

```sh
git add docker-compose.student.yml README.md docs/
git commit -m "chore: publish lab01 student image"
git push
```

### 10. 模拟学生环境验证

建议用另一台干净虚拟机验证。如果没有，也至少用新目录验证：

```sh
git clone <your-repo-url> linux-edge-lab-student-check
cd linux-edge-lab-student-check
docker compose -f docker-compose.student.yml pull lab
docker compose -f docker-compose.student.yml run --rm lab make lab01-build
docker compose -f docker-compose.student.yml run --rm lab make lab01-run
docker compose -f docker-compose.student.yml run --rm lab make lab01-check
```

确认验证流程里没有执行：

```sh
docker compose build lab
```

## 学生：首次使用 Lab01

### 1. 安装 Docker

学生只需要安装 Docker：

- Windows/macOS：安装 Docker Desktop，并启动 Docker；
- Linux：安装 Docker Engine 和 Docker Compose 插件。

学生不需要安装：

- `make`；
- Buildroot 源码；
- 交叉编译工具链；
- QEMU。

### 2. 拉取仓库

```sh
git clone <your-repo-url> linux-edge-lab
cd linux-edge-lab
```

### 3. 拉取课程镜像

```sh
docker compose -f docker-compose.student.yml pull lab
```

如果课程镜像是私有镜像，先登录镜像仓库：

```sh
docker login <registry-domain>
```

公开镜像不需要登录。

### 4. 运行 Lab01

```sh
docker compose -f docker-compose.student.yml run --rm lab make lab01-build
docker compose -f docker-compose.student.yml run --rm lab make lab01-run
docker compose -f docker-compose.student.yml run --rm lab make lab01-check
```

成功时应看到：

```text
LAB01 PASS
```

Linux 用户如果发现生成文件归属为其他用户，可以先执行：

```sh
export LAB_UID=$(id -u)
export LAB_GID=$(id -g)
```

然后重新运行实验命令。

### 5. 完成作业

修改：

```text
apps/edge-agent/main.c
```

把：

```c
#define EDGE_DEVICE_ID "student_demo"
```

改成自己的 ID，例如：

```c
#define EDGE_DEVICE_ID "student_20260001"
```

重新运行：

```sh
docker compose -f docker-compose.student.yml run --rm lab make lab01-build
docker compose -f docker-compose.student.yml run --rm lab make lab01-run
docker compose -f docker-compose.student.yml run --rm lab make lab01-check
```

## 后续发布 Lab02、Lab03

### 只改仓库代码时

如果新实验没有新增容器依赖，也没有更换 Buildroot 版本，教师只需要推送仓库代码：

```sh
git add .
git commit -m "lab02: add process and rootfs exercise"
git push
```

学生更新：

```sh
git pull
```

这些变化通常只需要更新仓库：

- 新增实验文档；
- 新增或修改 `apps/` 代码；
- 新增 Buildroot package 配置；
- 修改 rootfs overlay；
- 新增测试脚本；
- 新增 Makefile target，但仍然使用已有容器工具。

### 改了实验环境时

如果新实验需要修改 Docker 镜像，教师必须重新构建并发布镜像：

```sh
export IMAGE_REPO=ghcr.io/niuzhanaifu/linux-project-lab
export LAB_IMAGE_VERSION="$IMAGE_REPO:lab-v0.0.2"
export LAB_IMAGE_LATEST="$IMAGE_REPO:lab-stable"
export LOCAL_LAB_IMAGE="$LAB_IMAGE_VERSION"

docker compose build lab
docker compose run --rm lab make lab02-build
docker compose run --rm lab make lab02-check

docker push "$LAB_IMAGE_VERSION"
docker tag "$LAB_IMAGE_VERSION" "$LAB_IMAGE_LATEST"
docker push "$LAB_IMAGE_LATEST"
```

然后更新 `docker-compose.student.yml` 的默认镜像 tag，提交并推送仓库。

这些变化需要重新发布镜像：

- 修改 `Dockerfile`；
- 新增 apt 依赖；
- 更换 Buildroot 版本；
- 新增 Python 包或调试工具；
- 新增仿真器、烧录工具或交叉工具链；
- 希望把更多下载缓存提前放进镜像。

### 推荐学生固定更新命令

为了避免学生漏掉镜像更新，建议每次发布新实验都让学生执行：

```sh
git pull
docker compose -f docker-compose.student.yml pull lab
```

如果镜像没有变化，第二条命令成本很低；如果镜像变化了，学生也会自动同步。

## 发布前检查清单

教师发布前逐项确认：

- `docker compose build lab` 成功；
- 当前实验的 build/run/check 全部通过；
- 已执行 `make docker-preload-dl` 并重新构建镜像；
- 预构建镜像已经推送到学生可访问的仓库；
- `docker-compose.student.yml` 默认镜像已经改成正式 tag；
- 学生验证流程只使用 `docker-compose.student.yml`；
- 学生验证流程没有执行 `docker compose build`；
- README 和实验文档中的学生命令没有要求安装宿主机 `make`、Buildroot 或 QEMU。

## 常见问题

### 学生提示找不到 QEMU

通常说明学生没有通过 `docker-compose.student.yml` 运行，或者镜像不是最新版本。让学生执行：

```sh
docker compose -f docker-compose.student.yml pull lab
docker compose -f docker-compose.student.yml run --rm lab make lab01-run
```

### 学生提示找不到 make

说明学生可能直接在宿主机执行了 `make`。正确命令是：

```sh
docker compose -f docker-compose.student.yml run --rm lab make lab01-build
```

### 学生拉不到镜像

检查三件事：

- `docker-compose.student.yml` 里的镜像地址是否是真实地址；
- 镜像仓库是否公开；
- 如果是私有仓库，学生是否已经执行 `docker login <registry-domain>`。

### 第一次构建仍然下载源码包

镜像里已经包含 Buildroot 源码、QEMU 和发布前预热过的 Buildroot package 下载缓存。容器启动时会把镜像内的 `/opt/buildroot-dl` 同步到仓库的 `.cache/dl`。

如果学生侧第一次构建仍然下载源码包，通常说明教师发布镜像前没有执行 `make docker-preload-dl` 后重新构建镜像，或者新实验新增了缓存里没有的 package。
