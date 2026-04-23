@echo off
setlocal

:: ==========================================================
:: 1. Admin Privilege Check & Request
:: ==========================================================
:: Checks if the script is running with elevated privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [*] Requesting administrative privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ==========================================================
:: 2. Set Working Directory
:: ==========================================================
:: Ensures the script runs in its own directory (allows double-clicking)
cd /d "%~dp0"

:: ==========================================================
:: 3. MSBuild Localization
:: ==========================================================
echo [+] Locating MSBuild via vswhere...

for /f "usebackq delims=" %%i in (`
  "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
`) do (
  set "VS_PATH=%%i"
)

if not defined VS_PATH (
  echo [-] Visual Studio with MSBuild not found.
  pause
  exit /b 1
)

set "MSBUILD=%VS_PATH%\MSBuild\Current\Bin\MSBuild.exe"

if not exist "%MSBUILD%" (
  echo [-] MSBuild not found at: %MSBUILD%
  pause
  exit /b 1
)

echo [+] MSBuild found at:
echo     "%MSBUILD%"
echo.

:: ==========================================================
:: 4. Compilation
:: ==========================================================
cd EDK-II

if errorlevel 1 (
  echo [-] Failed to enter the EDK-II directory.
  pause
  exit /b 1
)

echo [+] Compiling EDK-II.sln...
"%MSBUILD%" EDK-II.sln /p:Configuration=Release /p:Platform=x64

if errorlevel 1 (
  echo [-] Build failed.
  pause
  exit /b 1
)

echo [+] Build completed successfully!

:: ==========================================================
:: 5. Create USER Environment Variable
:: ==========================================================
echo.
echo [+] Creating USER environment variable (VISUALUEFI_ROOT)...

:: %~dp0 always ends with a backslash. The logic below removes it for a clean path.
set "CURRENT_DIR=%~dp0"
set "VISUALUEFI_ROOT=%CURRENT_DIR:~0,-1%"

:: Sets the environment variable permanently for the current user.
:: Using quotes here is crucial for paths with spaces.
setx VISUALUEFI_ROOT "%VISUALUEFI_ROOT%" >nul

if errorlevel 1 (
    echo [-] Failed to create VISUALUEFI_ROOT environment variable.
    pause
    exit /b 1
)

echo [+] Variable created: %VISUALUEFI_ROOT%

:: ==========================================================
:: 6. Install Visual Studio Project Templates
:: ==========================================================
echo.
echo [+] Installing Project Templates (UEFI)...

:: PowerShell is the safest way to retrieve Windows special folders.
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "[Environment]::GetFolderPath('MyDocuments')"`) do set "DOCS_PATH=%%A"

if not defined DOCS_PATH (
    echo [-] Failed to locate the Documents folder via PowerShell.
    pause
    exit /b 1
)

:: Define the target path (Visual Studio 2022)
set "TEMPLATES_DIR=%DOCS_PATH%\Visual Studio 2022\Templates\ProjectTemplates"

echo     Documents folder detected at: %DOCS_PATH%

:: Create the templates folder (and subfolders) if they do not exist
if not exist "%TEMPLATES_DIR%" (
    echo     Creating target directory...
    mkdir "%TEMPLATES_DIR%"
)

:: Verify if the source file exists before copying
if exist "%VISUALUEFI_ROOT%\templates\UEFI Project.zip" (
    echo     Copying to: %TEMPLATES_DIR%
    copy /y "%VISUALUEFI_ROOT%\templates\UEFI Project.zip" "%TEMPLATES_DIR%\" >nul
    if errorlevel 1 (
        echo [-] Critical error while copying UEFI Project.zip.
    ) else (
        echo [+] Templates installed successfully!
    )
) else (
    echo [-] Error: Source file not found at: %VISUALUEFI_ROOT%\templates\
)

echo.
echo [!] Setup COMPLETE.
echo     1. Restart Visual Studio to update the templates cache.
echo     2. When creating a new project, search for "UEFI" in the search bar.
echo.

pause
endlocal