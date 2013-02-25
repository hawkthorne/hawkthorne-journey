setlocal EnableDelayedExpansion
echo off
cls
echo.

set arg="%0 %1"
if %arg%=="make run" (
    call:maps
    echo launching hawkthorne
    call:run
) else if %arg%=="make clean" (
    echo removing old files
    call:clean
) else (
    call:maps
)

goto:end

:maps
    if exist tmx2lua.exe (
        echo Found tmx2lua.exe
        call:tmx2lua
    ) else (

        for %%X in (tmx2lua.exe) do (set FOUND=%%~$PATH:X)

        if "!FOUND!"=="" (
            echo Cannot find tmx2lua.exe in the PATH
            echo You can download it here: https://github.com/kyleconroy/tmx2lua/downloads
            echo.
            pause
            goto:eof
        ) else (
            echo found !FOUND!
            call:tmx2lua
        )
    )
    goto:eof

:tmx2lua
echo Checking for outdated .lua files
for %%i in (src\maps\*.tmx) do (
	FOR /F %%j IN ('DIR /B /O:D src\maps\%%~ni.tmx src\maps\%%~ni.lua') DO SET NEWEST=%%~xj
	if "!NEWEST!"==".tmx" (
		tmx2lua src\maps\%%~ni.tmx
	)
)
goto:eof

:run
love src
goto:eof

:clean
rm src/maps/*.lua
goto:eof

:end
echo bye!