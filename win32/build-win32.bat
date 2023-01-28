REM build OpenSSL 3.0.8 with Perl, NASM and VS2019, May 2023

setlocal EnableDelayedExpansion

call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat"

set "MY_SCRIPT_PATH=%~dp0"
set "OUTPUT_LIBDIR=%~dp0\lib"

REM check OUTPUT_DIR
set "OUTPUT_DIR=%1"
if not defined OUTPUT_DIR set "OUTPUT_DIR=%~dp0build_win32_openssl"
mkdir "%OUTPUT_DIR%"

REM OpenSSL Configure needs absolute path
for /f "delims=" %%I in ("%OUTPUT_DIR%") do (
    set "OUTPUT_DIR=%%~fI"
)

REM tested with OpenSSL 3.0.8
set "OPENSSL_VERSION=openssl-3.0.8"
if not exist "%OUTPUT_DIR%\%OPENSSL_VERSION%.tar.gz" (
    curl -L "https://github.com/openssl/openssl/releases/download/%OPENSSL_VERSION%/%OPENSSL_VERSION%.tar.gz" -o "%OUTPUT_DIR%\%OPENSSL_VERSION%.tar.gz"
)
tar -xf "%OUTPUT_DIR%\%OPENSSL_VERSION%.tar.gz" --directory "%OUTPUT_DIR%"
set "OPENSSL_LOCAL_CONFIG_DIR=%MY_SCRIPT_PATH%\config"
cd "%OUTPUT_DIR%\%OPENSSL_VERSION%"

set "TARGET=VC-WIN32"
perl Configure %TARGET% threads no-shared --prefix="%OUTPUT_DIR%\builds\%TARGET%" --openssldir="%OUTPUT_DIR%\builds\%TARGET%"
nmake clean
nmake build_sw
nmake install_sw

xcopy "%OUTPUT_DIR%\builds\%TARGET%\lib\lib*.lib" "%OUTPUT_LIBDIR%\"
xcopy "%OUTPUT_DIR%\builds\%TARGET%\include" "%OUTPUT_LIBDIR%\include" /S /i
