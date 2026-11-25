# 一键部署到 GitHub（不需要安装 Git）
#
# 用法：
#   powershell -ExecutionPolicy Bypass -File .\deploy-via-api.ps1 -Token "ghp_xxxx" -Repo "lunaris-settings-zh"
#
# 需要先创建一个 Personal Access Token：
#   1. 打开 https://github.com/settings/tokens/new
#   2. Note 随便填，例如 lunaris-zh
#   3. Expiration 选 7 days
#   4. 勾选 scope：repo（整个复选框）、workflow
#   5. 拉到底点 Generate token，复制 ghp_ 开头的那串
#
# 脚本会：建仓库 → 逐个上传文件 → 打印 Actions 地址

param(
    [Parameter(Mandatory = $true)][string]$Token,
    [string]$Repo = "lunaris-settings-zh",
    [string]$CommitMessage = "Lunaris Settings ZH LSPosed module"
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = $PSScriptRoot
Set-Location $root

$headers = @{
    "Authorization"        = "Bearer $Token"
    "Accept"               = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent"           = "lunaris-zh-deploy"
}

Write-Host "==> 验证 token" -ForegroundColor Cyan
try {
    $me = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -Method Get
} catch {
    Write-Host "token 无效或网络不通：$($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
$owner = $me.login
Write-Host "  已登录：$owner" -ForegroundColor Green

Write-Host "==> 创建仓库 $Repo" -ForegroundColor Cyan
$body = @{ name = $Repo; private = $false; auto_init = $false } | ConvertTo-Json
try {
    $repoInfo = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $headers -Method Post -Body $body -ContentType "application/json"
    Write-Host "  仓库已创建" -ForegroundColor Green
    Start-Sleep -Seconds 2
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 422) {
        Write-Host "  仓库已存在，直接使用" -ForegroundColor Yellow
    } else {
        Write-Host "  创建失败：$($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "==> 收集文件" -ForegroundColor Cyan
$files = Get-ChildItem -LiteralPath $root -Recurse -File -Force |
    Where-Object { $_.FullName -notmatch '\\\.git\\' }
Write-Host "  共 $($files.Count) 个文件"

$ok = 0
$fail = 0
foreach ($f in $files) {
    $rel = $f.FullName.Substring($root.Length + 1).Replace('\', '/')
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $b64 = [Convert]::ToBase64String($bytes)

    $payload = @{
        message = $CommitMessage
        content = $b64
    } | ConvertTo-Json -Compress

    $uri = "https://api.github.com/repos/$owner/$Repo/contents/$rel"
    try {
        Invoke-RestMethod -Uri $uri -Headers $headers -Method Put -Body $payload -ContentType "application/json" | Out-Null
        Write-Host "  ✓ $rel" -ForegroundColor Green
        $ok++
    } catch {
        $code = $_.Exception.Response.StatusCode.value__
        if ($code -eq 422) {
            # 文件已存在，取 sha 后覆盖
            try {
                $existing = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
                $payload2 = @{ message = $CommitMessage; content = $b64; sha = $existing.sha } | ConvertTo-Json -Compress
                Invoke-RestMethod -Uri $uri -Headers $headers -Method Put -Body $payload2 -ContentType "application/json" | Out-Null
                Write-Host "  ✓ $rel (覆盖)" -ForegroundColor Green
                $ok++
            } catch {
                Write-Host "  ✗ $rel : $($_.Exception.Message)" -ForegroundColor Red
                $fail++
            }
        } else {
            Write-Host "  ✗ $rel : $($_.Exception.Message)" -ForegroundColor Red
            $fail++
        }
    }
    Start-Sleep -Milliseconds 300
}

Write-Host ""
Write-Host "上传完成：成功 $ok，失败 $fail" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Yellow" })
Write-Host ""
Write-Host "打开下面地址查看构建：" -ForegroundColor Cyan
Write-Host "  https://github.com/$owner/$Repo/actions" -ForegroundColor White
Write-Host ""
Write-Host "构建完成后在运行记录页面底部的 Artifacts 下载 LunarisSettingsZh.apk" -ForegroundColor Cyan
