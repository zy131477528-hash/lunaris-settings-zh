# Lunaris Settings 简体中文补全 — LSPosed 模块

| 项目 | 值 |
|---|---|
| 包名 | `com.mike.lunaris.zhcn` |
| 作用域 | `com.android.settings` |
| 词典条目 | 10311（去重后 1836 条唯一文案，全部人工翻译） |
| 生成日期 | 2026-11-24 |
| 数据来源 | Lunaris `Settings.apk`（versionName 16）`resources.arsc` |

## 目录

```
lsposed/
├── app/src/main/
│   ├── AndroidManifest.xml          # xposedmodule + xposedscope
│   ├── assets/xposed_init           # 入口类 com.mike.lunaris.zhcn.Module
│   ├── java/com/mike/lunaris/zhcn/
│   │   ├── Module.java              # hook Resources.getString / getText
│   │   └── ZhTable.java             # 自动生成，10311 条
│   └── res/values/arrays.xml        # 作用域数组
├── gradlew / gradlew.bat            # 自包含 wrapper（无需 gradle-wrapper.jar）
├── tools/gen_table.py               # 由 runtime_map.json 重新生成 ZhTable.java
├── tools/check_table.py             # 校验转义、重复键
├── tools/check_project.py           # 校验工程完整性
├── build.gradle / settings.gradle / gradle.properties
└── .github/workflows/build.yml      # GitHub Actions 自动出包
```

## 构建

### 方式 1：GitHub Actions（最省事，无需本地环境）
把 `lsposed/` 推送到仓库 → Actions 自动构建 → 在 Artifacts 下载 `LunarisSettingsZh.apk`。
推送用 `push-to-github.ps1` 一条命令搞定。

### 方式 2：本地命令行
需要 **JDK 17** 和 **Android SDK**（compileSdk 35）。

```bash
# Windows
gradlew.bat :app:assembleDebug

# macOS / Linux
chmod +x gradlew && ./gradlew :app:assembleDebug
```

首次运行会自动下载 Gradle 8.9 到 `~/.gradle/wrapper/dists/`。
SDK 路径写在 `local.properties` 里，**本地构建前先改成你自己的**：

```properties
sdk.dir=C\:\\Users\\你的用户名\\AppData\\Local\\Android\\Sdk
```

产物：`app/build/outputs/apk/debug/app-debug.apk`

### 方式 3：Android Studio
直接打开 `lsposed/` 目录，等 Gradle 同步完，Build → Build APK(s)。

## 安装与使用

1. 安装 APK
2. LSPosed → 模块 → 启用「Lunaris Settings 中文补全」
3. 作用域勾选 **设置（com.android.settings）**
4. 重启手机

验证：
```bash
adb shell logcat -s LunarisZh
# 期望输出：
# LunarisZh: loading in com.android.settings (com.android.settings)
# LunarisZh: hooks installed
```

## 常见问题

| 现象 | 排查 |
|---|---|
| LSPosed 里看不到模块 | `unzip -l app-debug.apk \| grep xposed_init` 确认入口文件在 assets 根目录 |
| 日志无输出 | 作用域没勾；或 LSPosed 未激活（需 Magisk/KernelSU + Zygisk） |
| 有日志但仍是英文 | 该文本走了 `getStringArray` / `getQuantityString`，把 logcat 调用栈发我补 hook |
| 设置崩溃 | LSPosed 会自动禁用模块；`adb logcat` 搜 `LunarisZh` 找异常 |

## 再生成词典

```bash
python3 tools/gen_table.py    # 读取 ../work/runtime_map.json
python3 tools/check_table.py  # 校验转义、重复键
python3 tools/check_project.py # 校验工程完整性
```

若换了新版 Settings.apk，先用解析脚本重新导出 `strings.json` / `runtime_map.json`，再跑上面三条。

## 与方案 A 的关系

本模块是**个人自用**方案（运行时替换）。
想要系统级、所有用户都生效，应走方案 A：把 `Lunaris-Settings-zh-CN-patch.zip` 里的补丁提交给 ROM 作者合并。两者的词典数据完全同源。
