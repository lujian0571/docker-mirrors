#!/usr/bin/env bash
#
# pull.sh
#
# Description:
#   Pull mirrored container images from a registry to local runtime (docker / nerdctl).
#   Supports full sync (images.txt) or single image sync (via command-line argument).
#
# Usage:
#   ./pull.sh                 # Full sync from IMAGES_FILE
#   ./pull.sh alpine:latest   # Single image sync
#   ./pull.sh maven:3.9=library/maven:3.9
#
# Environment Variables:
#   REGISTRY_PREFIX   Container registry prefix (default: ghcr.io/lujian0571)
#   RUNTIME           docker | nerdctl (default: docker)
#   IMAGES_FILE       Image list file (default: images.txt)
#
# Author: lujian
# Email: lujian0571@gmail.com
# Repository: https://github.com/lujian0571/docker-mirrors
# License: MIT
#

set -euo pipefail

# ===== 可配置区 =====
REGISTRY_PREFIX="${REGISTRY_PREFIX:-ghcr.io/lujian0571}"
RUNTIME="${RUNTIME:-docker}"
IMAGES_FILE="${IMAGES_FILE:-images.txt}"
# ====================

# 单镜像模式参数
TARGET_ARG="${1:-}"

# 检查 runtime 是否存在
if ! command -v "$RUNTIME" >/dev/null 2>&1; then
  echo "❌ Runtime '$RUNTIME' not found"
  exit 1
fi

# 同步函数
process_image() {
  local line="$1"
  local SRC DST REMOTE_IMAGE LOCAL_IMAGE

  # 支持 SRC=DST 映射
  if [[ "$line" == *"="* ]]; then
    SRC="${line%%=*}"   # = 左边为源镜像
    DST="${line#*=}"    # = 右边为目标镜像
  else
    SRC="$line"
    DST="$line"
  fi

  REMOTE_IMAGE="$REGISTRY_PREFIX/$DST"
  LOCAL_IMAGE="$DST"

  echo ">>> Pull $REMOTE_IMAGE"
  $RUNTIME pull "$REMOTE_IMAGE"

  # 如果远程名和本地名不一致，进行 tag
  if [ "$REMOTE_IMAGE" != "$LOCAL_IMAGE" ]; then
    echo ">>> Tag $REMOTE_IMAGE -> $LOCAL_IMAGE"
    $RUNTIME tag "$REMOTE_IMAGE" "$LOCAL_IMAGE"
  fi

  echo "✔ Pulled $LOCAL_IMAGE"
  echo
}

echo ">>> Runtime  : $RUNTIME"
echo ">>> Registry : $REGISTRY_PREFIX"
echo

# ===== 单镜像模式 =====
if [ -n "$TARGET_ARG" ]; then
  echo ">>> Single image mode: $TARGET_ARG"
  process_image "$TARGET_ARG"
  exit 0
fi

# ===== 全量模式 =====
echo ">>> Full sync mode from $IMAGES_FILE"
while IFS= read -r line; do
  [ -z "$line" ] && continue            # 跳过空行
  case "$line" in \#*) continue ;; esac # 跳过注释
  process_image "$line"
done < "$IMAGES_FILE"
