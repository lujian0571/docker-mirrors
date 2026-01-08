# Docker 镜像同步工具

一个自动同步 Docker 镜像的工具，支持从源镜像仓库同步到目标镜像仓库，并提供本地拉取功能。

## 功能特性

- **自动化同步**：通过 GitHub Actions 每 6 小时自动同步一次镜像
- **手动触发**：支持手动触发同步任务，可指定单个镜像或自定义参数
- **镜像重命名**：支持源镜像到目标镜像的重命名映射
- **多平台支持**：使用 Skopeo 工具同步所有架构的镜像
- **智能同步**：自动比较源镜像和目标镜像的摘要（digest），仅在镜像发生变化时才执行同步
- **本地拉取**：提供脚本从镜像仓库拉取镜像到本地运行时

## 工作流程

### 自动同步

- **定时触发**：每 6 小时运行一次 (`0 */6 * * *`)
- **推送触发**：当代码推送到 main 分支时自动运行
- **手动触发**：支持通过 GitHub Actions 界面手动触发

### 配置参数

工作流支持以下参数：

- `IMAGE`：指定单个镜像同步（可选），格式如 `alpine:latest` 或 `library/alpine:latest=alpine:latest`
- `TARGET_REGISTRY`：目标镜像仓库地址（可选），格式为 `<registry-url>[/<namespace>]`，例如 `ghcr.io/lujian0571` 或 `my-registry.com/my-namespace`
- `REGISTRY_USERNAME`：目标仓库用户名（可选）
- `REGISTRY_PASSWORD`：目标仓库密码/Token（可选）

### 优先级顺序

参数优先级从高到低：

1. 手工输入参数
2. Environment Secret
3. 默认值（GHCR + GitHub 用户名 + GitHub Token）

### 阿里云容器镜像服务配置示例

如果您使用阿里云容器镜像服务（ACR），请按以下方式配置：

1. 在 GitHub 仓库的 Secrets 中配置：
   - `TARGET_REGISTRY`：`<instance-id>.cr.aliyuncs.com/<your-namespace>` （替换为您的阿里云镜像仓库地址和命名空间）
   - `REGISTRY_USERNAME`：阿里云 ACR 用户名
   - `REGISTRY_PASSWORD`：阿里云 ACR 访问凭证/Token

2. 阿里云容器镜像服务分为个人版和企业版：
   - **个人版**（免费）：使用公共实例，格式为 `registry.cn-<region>.aliyuncs.com/<your-namespace>`
     - 华东1（杭州）：`registry.cn-hangzhou.aliyuncs.com/<your-namespace>`
     - 华北1（北京）：`registry.cn-beijing.aliyuncs.com/<your-namespace>`
     - 华南1（深圳）：`registry.cn-shenzhen.aliyuncs.com/<your-namespace>`
     - 华东2（上海）：`registry.cn-shanghai.aliyuncs.com/<your-namespace>`
     - 西南1（成都）：`registry.cn-chengdu.aliyuncs.com/<your-namespace>`
     - 中国香港：`registry.cn-hongkong.aliyuncs.com/<your-namespace>`
   
   - **企业版**：使用专有实例，格式为 `<your-instance-id>.registry.aliyuncs.com/<your-namespace>`
     - 需要在阿里云控制台创建专属实例，获得唯一的实例ID

3. 其他地域支持（根据实际可用区选择）：
   - 新加坡：`registry.ap-southeast-1.aliyuncs.com/<your-namespace>`
   - 东京：`registry.ap-northeast-1.aliyuncs.com/<your-namespace>`
   - 弗吉尼亚：`registry.us-west-1.aliyuncs.com/<your-namespace>`
   - 法兰克福：`registry.eu-central-1.aliyuncs.com/<your-namespace>`

其中 `<your-namespace>` 是您在阿里云容器镜像服务中创建的命名空间，用于组织和管理您的镜像。

**阿里云容器镜像服务控制台地址**：[https://cr.console.aliyun.com/](https://cr.console.aliyun.com/)

## 智能同步机制

- **摘要比较**：系统会获取源镜像和目标镜像的摘要（digest）
- **变化检测**：只有当两个镜像的摘要不同时才会执行同步操作
- **性能优化**：如果目标镜像不存在或与源镜像不同，则执行同步
- **跳过同步**：如果源镜像和目标镜像的摘要相同，则跳过同步操作

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

### 单镜像同步

可以通过 GitHub Actions 手动触发单镜像同步：

1. 进入仓库的 Actions 页面
2. 选择 "Sync Images" 工作流
3. 点击 "Run workflow"
4. 在 `IMAGE` 字段中输入要同步的镜像名称，例如：
   - `alpine:latest`：同步 alpine:latest 镜像
   - `library/alpine:latest=alpine:latest`：将 library/alpine:latest 重命名为 alpine:latest 同步

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