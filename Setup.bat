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

@echo off
setlocal
:: ==========================================================
:: 5. Criação da variável de ambiente de USUÁRIO
:: ==========================================================

echo.
echo [+] Criando variavel de ambiente de USUARIO (VISUALUEFI_ROOT)...

:: %~dp0 já termina com \, o script abaixo remove a última barra para ficar um caminho limpo
set "CURRENT_DIR=%~dp0"
set "VISUALUEFI_ROOT=%CURRENT_DIR:~0,-1%"

:: Define a variável de ambiente permanentemente para o usuário atual
:: O uso das aspas aqui é crucial para caminhos com espaços
setx VISUALUEFI_ROOT "%VISUALUEFI_ROOT%" >nul

if errorlevel 1 (
    echo [-] Falha ao criar a variavel de ambiente VISUALUEFI_ROOT.
    pause
    exit /b 1
)

echo [+] Variavel criada: %VISUALUEFI_ROOT%


:: ==========================================================
:: 7. Instalação dos Templates de Projeto do Visual Studio
:: ==========================================================

echo.
echo [+] Instalando Templates de Projeto (UEFI)...

:: PowerShell é a forma mais segura de obter pastas especiais do Windows
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "[Environment]::GetFolderPath('MyDocuments')"`) do set "DOCS_PATH=%%A"

if not defined DOCS_PATH (
    echo [-] Nao foi possivel localizar a pasta Documentos via PowerShell.
    pause
    exit /b 1
)

:: Define o caminho de destino (Visual Studio 2022)
set "TEMPLATES_DIR=%DOCS_PATH%\Visual Studio 2022\Templates\ProjectTemplates"

echo     Detectado Documentos em: %DOCS_PATH%

:: Cria a pasta de templates (e subpastas) se não existir
if not exist "%TEMPLATES_DIR%" (
    echo     Criando pasta de destino...
    mkdir "%TEMPLATES_DIR%"
)

:: Verifica se o arquivo de origem existe antes de copiar
if exist "%VISUALUEFI_ROOT%\templates\UEFI Project.zip" (
    echo     Copiando para: %TEMPLATES_DIR%
    copy /y "%VISUALUEFI_ROOT%\templates\UEFI Project.zip" "%TEMPLATES_DIR%\" >nul
    if errorlevel 1 (
        echo [-] Erro critico ao copiar UEFI Project.zip
    ) else (
        echo [+] Templates instalados com sucesso!
    )
) else (
    echo [-] Erro: Arquivo de origem nao encontrado em: %VISUALUEFI_ROOT%\templates\
)

echo.
echo [!] Setup COMPLETO.
echo     1. Reinicie o Visual Studio para atualizar o cache de templates.
echo     2. Ao criar novo projeto, procure por "UEFI" na barra de busca.
echo.

pause
endlocal