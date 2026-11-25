@echo off
REM Gradle Wrapper bootstrap for Windows (minimal, no gradle-wrapper.jar required)
REM
REM 用法: gradlew.bat :app:assembleDebug
REM
REM 首次运行会下载 gradle-wrapper.properties 指定的 Gradle 版本到
REM %USERPROFILE%\.gradle\wrapper\dists\ 下。
REM
REM 注意：这是简化版。要生成标准 wrapper，在有 Gradle 的机器上执行一次：
REM   gradle wrapper --gradle-version 8.9

setlocal enabledelayedexpansion

set "APP_HOME=%~dp0"
if "%APP_HOME:~-1%"=="\" set "APP_HOME=%APP_HOME:~0,-1%"

set "PROPS=%APP_HOME%\gradle\wrapper\gradle-wrapper.properties"
if not exist "%PROPS%" (
    echo ERROR: %PROPS% not found
    exit /b 1
)

set "DIST_URL="
for /f "usebackq tokens=1,* delims==" %%A in ("%PROPS%") do (
    if "%%A"=="distributionUrl" set "DIST_URL=%%B"
)

if "%DIST_URL%"=="" (
    echo ERROR: distributionUrl not found in gradle-wrapper.properties
    exit /b 1
)

REM 去掉转义的反斜杠冒号
set "DIST_URL=!DIST_URL:\:=:!"

REM 取文件名
for %%F in ("!DIST_URL!") do set "ZIP_NAME=%%~nxF"
set "DIST_NAME=!ZIP_NAME:.zip=!"

if "%GRADLE_USER_HOME%"=="" set "GRADLE_USER_HOME=%USERPROFILE%\.gradle"

set "DIST_DIR=%GRADLE_USER_HOME%\wrapper\dists\!DIST_NAME!"
set "GRADLE_BIN=%DIST_DIR%\!DIST_NAME!\bin\gradle.bat"
set "ZIP_PATH=%DIST_DIR%\!ZIP_NAME!"

if not exist "!GRADLE_BIN!" (
    echo Downloading !DIST_URL! ...
    if not exist "!DIST_DIR!" mkdir "!DIST_DIR!"
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '!DIST_URL!' -OutFile '!ZIP_PATH!'"
    if errorlevel 1 (
        echo ERROR: download failed
        exit /b 1
    )
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Expand-Archive -LiteralPath '!ZIP_PATH!' -DestinationPath '!DIST_DIR!' -Force"
    if errorlevel 1 (
        echo ERROR: unzip failed
        exit /b 1
    )
    del /q "!ZIP_PATH!" 2>nul
)

call "!GRADLE_BIN!" %*
endlocal
