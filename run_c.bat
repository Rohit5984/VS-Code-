@echo off
setlocal

set "VSROOT=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
call "%VSROOT%\VC\Auxiliary\Build\vcvarsall.bat" x64 >nul 2>&1

set "FILE=%~1"
set "BASE=%~n1"

if /i "%~x1"==".c" (
    cl "%FILE%" /Fe:"%BASE%.exe" /std:c11 /nologo
) else if /i "%~x1"==".cpp" (
    cl "%FILE%" /Fe:"%BASE%.exe" /std:c++20 /nologo
) else if /i "%~x1"==".cc" (
    cl "%FILE%" /Fe:"%BASE%.exe" /std:c++20 /nologo
) else (
    cl "%FILE%" /Fe:"%BASE%.exe" /nologo
)

if %errorlevel% equ 0 (
    if exist "%BASE%.exe" (
        "%BASE%.exe"
    )
)

endlocal
