<#
.SYNOPSIS
  把 LSPosed 工程推送到 GitHub 空仓库

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\push-to-github.ps1 -RepoUrl "https://github.com/yourname/lunaris-settings-zh.git"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$RepoUrl,

    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
Set-Location $root

Write-Host "==> 检查 git" -ForegroundColor Cyan
try {
    git --version | Out-Null
} catch {
    Write-Host "未找到 git，请先安装：https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

Write-Host "==> 检查关键文件" -ForegroundColor Cyan
$required = @(
    "app\build.gradle",
    "app\src\main\AndroidManifest.xml",
    "app\src\main\assets\xposed_init",
    "app\src\main\java\com\mike\lunaris\zhcn\Module.java",
    "app\src\main\java\com\mike\lunaris\zhcn\ZhTable.java",
    "app\src\main\res\values\arrays.xml",
    "build.gradle",
    "settings.gradle",
    "gradle.properties",
    "local.properties",
    ".github\workflows\build.yml"
)
$missing = @()
foreach ($f in $required) {
    if (-not (Test-Path $f)) { $missing += $f }
}
if ($missing.Count -gt 0) {
    Write-Host "缺少文件：" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host "`n请确认在解压后的 lsposed 目录下运行本脚本" -ForegroundColor Yellow
    exit 1
}
Write-Host "  全部就位" -ForegroundColor Green

Write-Host "==> 初始化仓库" -ForegroundColor Cyan
if (-not (Test-Path ".git")) {
    git init | Out-Null
}
git branch -M $Branch 2>&1 | Out-Null

Write-Host "==> 添加文件（含隐藏目录 .github）" -ForegroundColor Cyan
git add -A

Write-Host "  将要提交的文件：" -ForegroundColor Gray
git status --short

Write-Host "==> 提交" -ForegroundColor Cyan
git -c user.name="LunarisZH" -c user.email="lunariszh@local" commit -m "Lunaris Settings 简体中文补全 LSPosed 模块" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  没有新改动可提交，继续" -ForegroundColor Yellow
} else {
    Write-Host "  提交成功" -ForegroundColor Green
}

Write-Host "==> 绑定远端" -ForegroundColor Cyan
$existing = git remote 2>$null
if ($existing -contains "origin") {
    git remote set-url origin $RepoUrl
} else {
    git remote add origin $RepoUrl
}

Write-Host "==> 推送到 $Branch" -ForegroundColor Cyan
git push -u origin $Branch

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n完成！" -ForegroundColor Green
    Write-Host "打开 GitHub 仓库的 Actions 页查看构建进度" -ForegroundColor Green
} else {
    Write-Host "`n推送失败。常见原因：" -ForegroundColor Red
    Write-Host "  1. 仓库不是空的（建仓库时勾了 README）——先在网页上删除 README 或改用 force push" -ForegroundColor Yellow
    Write-Host "  2. 没权限——检查账号密码 / PAT 是否正确" -ForegroundColor Yellow
    Write-Host "  3. 网络问题——重试一次" -ForegroundColor Yellow
}
