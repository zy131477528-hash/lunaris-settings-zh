# 方式 A：用 GitHub Actions 出包（无需本地环境）

拿到 APK 一共 6 步，全程在浏览器里操作，大约 5 分钟。

---

## 第 1 步：准备 GitHub 账号

没有的话去 <https://github.com> 注册一个（免费）。有 Root / KernelSU 的手机上直接注册也行。

---

## 第 2 步：新建一个仓库

1. 网址栏打开 <https://github.com/new>
2. **Repository name** 随便填，例如 `lunaris-settings-zh`
3. 可见性选 **Public**（私有也行，但 Actions 免费额度会受限）
4. **不要**勾 "Add a README file"
5. 点 **Create repository**

---

## 第 3 步：把工程文件传上去

页面会显示一个空仓库，点中间的 **"uploading an existing file"** 链接。

然后把你解压后的 `lsposed/` 里的内容拖进浏览器窗口：

```
AndroidManifest.xml → 不需要，顶层没有这个文件
要传的：
├── app/
│   └── build.gradle
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml
│       │   ├── assets/xposed_init
│       │   ├── java/com/mike/lunaris/zhcn/
│       │   │   ├── Module.java
│       │   │   └── ZhTable.java      ← 最大的那个，约 900 KB
│       │   └── res/values/arrays.xml
├── .github/workflows/build.yml
├── build.gradle
├── settings.gradle
├── gradle.properties
└── local.properties
```

**注意**：`.github` 是隐藏文件夹，Windows 资源管理器里默认看不见。
如果你在文件管理里看不到它，按这个顺序操作：
- 资源管理器 → 查看 → 勾选「隐藏的项目」
- 或者直接把整个 `lsposed` 文件夹拖进去（有些浏览器支持拖文件夹，会保留结构）

底部 **Commit changes** 提交。

> **更省事的替代方案**：如果你是直接拖文件夹，Chrome/Edge 在 Windows 上有时会丢掉 `.github`。稳妥点就装个 [GitHub Desktop](https://desktop.github.com/)，选 "Clone repository" → 把你的文件夹拖进去 → Commit → Push。

---

## 第 4 步：等 Actions 跑完

1. 进你的仓库 → 顶部 **Actions** 标签
2. 会看到 `Build Lunaris Settings ZH` 正在跑（黄色圆点）
3. 点进去看日志，正常大约 2–4 分钟
4. 绿色对勾 = 成功

**如果失败了**，展开失败的步骤：
- `Build debug APK` 挂了 → 把报错贴给我
- `Set up Android SDK` 挂了 → 重跑一次（偶尔网络问题）

---

## 第 5 步：下载 APK

1. 在跑完的那次 Workflow 页面底部
2. 找 **Artifacts** 区块
3. 点 **LunarisSettingsZh** 下载
4. 得到 `LunarisSettingsZh.zip`，解压出 `app-debug.apk`

---

## 第 6 步：装到手机

```bash
# 手机上装
adb install -r app-debug.apk

# 验证模块被识别
adb shell dumpsys package com.mike.lunaris.zhcn | findstr xposed
```

然后：
1. 打开 **LSPosed** → 模块
2. 启用「Lunaris Settings 中文补全」
3. 作用域勾选 **设置（com.android.settings）** —— 清单里已声明，一般会自动勾上
4. 重启手机

---

## 验证生效

```bash
adb shell logcat -s LunarisZh
```

看到这两行就成功：
```
LunarisZh: loading in com.android.settings (com.android.settings)
LunarisZh: hooks installed
```

---

## 常见报错对照

| 报错 | 原因 | 解决 |
|---|---|---|
| `./gradlew: No such file or directory` | 工作流用了 `./gradlew` | **已改**：现在用 `gradle` 命令（setup-gradle 会提供） |
| `Could not find repository api.xposed.info` | Maven 地址语法旧 | **已改**：`url = uri(...)` |
| `lintOptions` 报错 | AGP 8 弃用 | **已改**：换成 `lint { }` |
| `Failed to find target with hash string 'android-35'` | 仓库里没 `local.properties` | **已处理**：已放 `local.properties` |
| `Your build is currently configured to use Java 17...` | JDK 版本不对 | setup-java 已固定 17 |
| 成功但 APK 是 0 字节 / 404 | `xposed_init` 没在 assets 根目录 | 检查 `app/src/main/assets/xposed_init` 是否存在 |

---

## 改完每次都会自动重新构建

以后你改了 `ZhTable.java`（比如重跑词典生成），推上去就会自动重新出包。
也可以不推代码，直接在 **Actions → Build → Run workflow** 手动触发。
