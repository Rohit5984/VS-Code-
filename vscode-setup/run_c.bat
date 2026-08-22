@echo off
if "%~1"=="" (
    echo Usage: %~nx0 ^<file.c^|file.cpp^>
    exit /b 1
)

if not exist "%~1" (
    echo Error: file "%~1" not found
    exit /b 1
)

setlocal
set "FILE=%~1"
set "BASE=%~n1"
set "EXT=%~x1"
set "VSROOT=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
set "SDKROOT=C:\Program Files (x86)\Windows Kits\10"

rem Pick newest MSVC toolchain directly - avoids slow vcvarsall.bat setup
set "MSVC_VER="
for /f "delims=" %%v in ('dir /b /ad "%VSROOT%\VC\Tools\MSVC" 2^>nul ^| sort') do set "MSVC_VER=%%v"
set "SDK_VER="
for /f "delims=" %%v in ('dir /b /ad "%SDKROOT%\Include" 2^>nul ^| sort') do set "SDK_VER=%%v"

if defined MSVC_VER if defined SDK_VER if exist "%VSROOT%\VC\Tools\MSVC\%MSVC_VER%\bin\Hostx64\x64\cl.exe" (
    set "PATH=%VSROOT%\VC\Tools\MSVC\%MSVC_VER%\bin\Hostx64\x64;%PATH%"
    set "INCLUDE=%VSROOT%\VC\Tools\MSVC\%MSVC_VER%\include;%SDKROOT%\Include\%SDK_VER%\ucrt;%SDKROOT%\Include\%SDK_VER%\shared;%SDKROOT%\Include\%SDK_VER%\um;%SDKROOT%\Include\%SDK_VER%\winrt;%SDKROOT%\Include\%SDK_VER%\cppwinrt"
    set "LIB=%VSROOT%\VC\Tools\MSVC\%MSVC_VER%\lib\x64;%SDKROOT%\Lib\%SDK_VER%\ucrt\x64;%SDKROOT%\Lib\%SDK_VER%\um\x64"
    goto :compile
)

echo Setting up Visual Studio environment...
endlocal & set "FILE=%FILE%" & set "BASE=%BASE%" & set "EXT=%EXT%"
call "%VSROOT%\VC\Auxiliary\Build\vcvarsall.bat" x64 >nul || (
    echo Error: Failed to set up Visual Studio environment
    exit /b 1
)

:compile
if /i "%EXT%"==".c" (
    cl "%FILE%" /Fe:"%BASE%.exe" /std:c17 /W4 /utf-8 /diagnostics:caret /nologo
) else if /i "%EXT%"==".cpp" (
    cl "%FILE%" /Fe:"%BASE%.exe" /std:c++20 /EHsc /W4 /utf-8 /Zc:__cplusplus /diagnostics:caret /nologo
) else (
    echo Error: Unsupported file extension "%EXT%"
    exit /b 1
)

if errorlevel 1 (
    echo Error: Compilation failed
    exit /b 1
)

if exist "%BASE%.obj" del "%BASE%.obj"

"%BASE%.exe"
set "EC=%errorlevel%"
exit /b %EC%
