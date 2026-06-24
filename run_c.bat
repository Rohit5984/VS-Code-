@echo off
if "%~1"=="" (
    echo Usage: %~nx0 ^<file.c^|file.cpp^>
    exit /b 1
)

if not exist "%~1" (
    echo Error: file "%~1" not found
    exit /b 1
)

set "FILE=%~1"
set "BASE=%~n1"
set "EXT=%~x1"

if not defined VSCMD_VER (
    echo Setting up Visual Studio environment...
    call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64 >nul
    if errorlevel 1 (
        echo Error: Failed to set up Visual Studio environment
        exit /b 1
    )
)

echo Compiling %FILE%...
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

echo Running %BASE%.exe...
echo ================================
"%BASE%.exe"
set "EXITCODE=%errorlevel%"
echo ================================
echo Exit code: %EXITCODE%
exit /b %EXITCODE%
