@echo off
chcp 65001 >nul

REM 检查是否已安装Git
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到Git，请先安装并添加到系统路径。
    pause
    exit /b
)

:input
set "REPO_URL="
set "CLONE_DIR="
set "BRANCH_NAME="
set "FOLDER_PATH="

echo.
set /p "REPO_URL=请输入Git仓库地址（例如 https://github.com/用户/仓库.git）: "
set /p "CLONE_DIR=请输入目标文件夹名称（将自动创建）: "
set /p "BRANCH_NAME=请输入分支名称（默认main）: "
set /p "FOLDER_PATH=请输入要检出的目录（多个目录用空格分隔）: "

REM 设置默认分支为main
if "%BRANCH_NAME%"=="" set "BRANCH_NAME=main"

REM 验证必要输入
if "%REPO_URL%"=="" (
    echo 错误: 仓库地址不能为空
    goto input
)
if "%CLONE_DIR%"=="" (
    echo 错误: 文件夹名称不能为空
    goto input
)

REM 检查目标文件夹是否存在
if exist "%CLONE_DIR%" (
    echo 错误: 文件夹 "%CLONE_DIR%" 已存在
    choice /c YN /m "是否删除现有文件夹？(Y/N)"
    if %errorlevel%==2 exit /b
    rmdir /s /q "%CLONE_DIR%"
)

echo.
echo ====== 开始稀疏克隆操作 ======

REM 克隆仓库（仅元数据）
git clone --filter=blob:none --no-checkout "%REPO_URL%" "%CLONE_DIR%"
if %errorlevel% neq 0 (
    echo 错误: 仓库克隆失败
    pause
    exit /b
)

pushd "%CLONE_DIR%"

REM 配置稀疏检出
git sparse-checkout init --cone 2>&1
git sparse-checkout set %FOLDER_PATH% 2>&1

REM 获取指定分支并切换
git remote set-branches origin "%BRANCH_NAME%"
git fetch --depth 1 origin "%BRANCH_NAME%"
git checkout "%BRANCH_NAME%"

popd

echo.
echo ====== 操作成功完成 ======
echo 已检出目录: %FOLDER_PATH%
echo 位置: %CD%\%CLONE_DIR%\
pause