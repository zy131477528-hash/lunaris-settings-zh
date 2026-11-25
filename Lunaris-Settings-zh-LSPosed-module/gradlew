#!/usr/bin/env sh
#
# Gradle Wrapper bootstrap (minimal, no gradle-wrapper.jar required)
#
# 用法：./gradlew :app:assembleDebug
#
# 这个脚本不需要 gradle-wrapper.jar。首次运行时如果本机没有 Gradle，
# 会下载 gradle/wrapper/gradle-wrapper.properties 里指定的版本到
# ~/.gradle/wrapper/dists/，然后用它执行构建。
#
# 注意：这是简化版，仅支持本项目常见用法。要生成标准 wrapper，
# 在有 Gradle 的机器上执行一次：gradle wrapper --gradle-version 8.9

set -e

APP_HOME=$(cd "$(dirname "$0")" && pwd)
PROPS="$APP_HOME/gradle/wrapper/gradle-wrapper.properties"

if [ ! -f "$PROPS" ]; then
    echo "ERROR: $PROPS not found" >&2
    exit 1
fi

DIST_URL=$(grep '^distributionUrl=' "$PROPS" | cut -d'=' -f2- | sed 's/\\:/:/g')
DIST_NAME=$(basename "$DIST_URL" .zip)
GRADLE_USER_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"
DIST_DIR="$GRADLE_USER_HOME/wrapper/dists/$DIST_NAME"
GRADLE_BIN="$DIST_DIR/$DIST_NAME/bin/gradle"

if [ ! -x "$GRADLE_BIN" ]; then
    echo "Downloading $DIST_URL ..."
    mkdir -p "$DIST_DIR"
    TMP="$DIST_DIR/$DIST_NAME.zip"
    if command -v curl >/dev/null 2>&1; then
        curl -fL --retry 3 -o "$TMP" "$DIST_URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$TMP" "$DIST_URL"
    else
        echo "ERROR: need curl or wget to download Gradle" >&2
        exit 1
    fi
    (cd "$DIST_DIR" && unzip -q -o "$TMP" && rm -f "$TMP")
    chmod +x "$GRADLE_BIN"
fi

exec "$GRADLE_BIN" "$@"
