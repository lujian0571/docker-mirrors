# Docker 镜像同步工具

一个自动同步 Docker 镜像的工具，支持从源镜像仓库同步到目标镜像仓库，并提供本地拉取功能。

## 功能特性

- **自动化同步**：通过 GitHub Actions 每 6 小时自动同步一次镜像
- **手动触发**：支持手动触发同步任务，可指定单个镜像或自定义参数
- **镜像重命名**：支持源镜像到目标镜像的重命名映射
- **多平台支持**：使用 Skopeo 工具同步所有架构的镜像
- **本地拉取**：提供脚本从镜像仓库拉取镜像到本地运行时

## 工作流程

### 自动同步

- **定时触发**：每 6 小时运行一次 (`0 */6 * * *`)
- **推送触发**：当代码推送到 main 分支时自动运行
- **手动触发**：支持通过 GitHub Actions 界面手动触发

### 配置参数

工作流支持以下参数：

- `IMAGE`：指定单个镜像同步（可选）
- `TARGET_REGISTRY`：目标镜像仓库地址（可选）
- `REGISTRY_USERNAME`：目标仓库用户名（可选）
- `REGISTRY_PASSWORD`：目标仓库密码/Token（可选）

### 优先级顺序

参数优先级从高到低：

1. 手动输入参数
2. Environment Secret
3. 默认值（GHCR + GitHub 用户名 + GitHub Token）

## 使用方法

### 镜像列表配置

在 [images.txt](./images.txt) 文件中配置需要同步的镜像，支持以下格式：

```
# 注释以 # 开头
alpine:latest
nginx:latest
redis:alpine
library/maven:3.9=library/maven:3.9
```

支持两种格式：
- `镜像名:标签`：直接同步
- `源镜像=目标镜像`：镜像重命名映射

### 本地拉取脚本

使用 [pull.sh](./pull.sh) 脚本可以从镜像仓库拉取镜像到本地：

```bash
# 拉取 images.txt 文件中的所有镜像
./pull.sh

# 拉取单个镜像
./pull.sh alpine:latest

# 拉取并重命名镜像
./pull.sh maven:3.9=library/maven:3.9
```

#### 环境变量

- `REGISTRY_PREFIX`：容器仓库前缀（默认：ghcr.io/lujian0571）
- `RUNTIME`：运行时（docker | nerdctl，默认：docker）
- `IMAGES_FILE`：镜像列表文件（默认：images.txt）

## 配置说明

### GitHub Actions Secrets

在 GitHub 仓库的 Secrets 中配置以下参数（可选）：

- `TARGET_REGISTRY`：目标镜像仓库地址
- `REGISTRY_USERNAME`：目标仓库用户名
- `REGISTRY_PASSWORD`：目标仓库密码/Token

### Environment 配置

工作流使用 `production` 环境，可修改为 `staging` 或其他环境。

## 技术栈

- **Skopeo**：用于镜像复制和同步
- **GitHub Actions**：CI/CD 自动化
- **Bash**：本地脚本

## 仓库结构

```
├── images.txt          # 镜像列表文件
├── pull.sh             # 本地拉取脚本
├── .github/workflows/
│   └── sync-images.yml # GitHub Actions 工作流
├── LICENSE             # MIT License
└── README.md           # 项目说明
```


## LICENSE

本项目使用 MIT License，详见 LICENSE


## 贡献

欢迎 fork、提交 issue 或 pull request。
请保持 images.txt 规范，确保 CI workflow 可正常运行。


## 作者

- lujian
- Email: lujian0571@gmail.com
- GitHub: lujian0571￼