git clone https://github.com/tianocore/edk2.git

:: ==========================================================
:: 3. Localização do MSBuild
:: ==========================================================

echo [+] Localizando MSBuild via vswhere...

for /f "usebackq delims=" %%i in (`
  "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
`) do (
  set "VS_PATH=%%i"
)

if not defined VS_PATH (
  echo [-] Visual Studio com MSBuild nao encontrado.
  pause
  exit /b 1
)

set "MSBUILD=%VS_PATH%\MSBuild\Current\Bin\MSBuild.exe"

if not exist "%MSBUILD%" (
  echo [-] MSBuild nao encontrado em: %MSBUILD%
  pause
  exit /b 1
)

echo [+] MSBuild encontrado em:
echo     "%MSBUILD%"
echo.

:: ==========================================================
:: 4. Compilação
:: ==========================================================

cd EDK-II

if errorlevel 1 (
  echo [-] Falha ao entrar em EDK-II.
  pause
  exit /b 1
)

echo [+] Compilando EDK-II.sln...
"%MSBUILD%" EDK-II.sln /p:Configuration=Release /p:Platform=x64

if errorlevel 1 (
  echo [-] Build falhou.
  pause
  exit /b 1
)

echo [+] Build concluido com sucesso!

:: ==========================================================
:: 5. Criação da variável de ambiente de USUÁRIO
:: ==========================================================


echo.
echo [+] Criando variavel de ambiente de USUARIO (VISUALUEFI_ROOT)...

set "CURRENT_DIR=%~dp0"
set "VISUALUEFI_ROOT=%CURRENT_DIR:~0,-1%"

:: Define a variável de ambiente para o usuário atual
setx VISUALUEFI_ROOT "%VISUALUEFI_ROOT%"

if errorlevel 1 (
    echo [-] Falha ao criar a variavel de ambiente VISUALUEFI_ROOT.
    pause
    exit /b 1
)

echo [+] Variavel criada: %VISUALUEFI_ROOT%