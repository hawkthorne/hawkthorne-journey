setlocal EnableDelayedExpansion
echo off
cls
echo.

if exist tmx2lua.exe (
	echo Found tmx2lua.exe
	goto :tmx2lua
) else (

	for %%X in (tmx2lua.exe) do (set FOUND=%%~$PATH:X)

	if "!FOUND!"=="" (
		echo Cannot find tmx2lua.exe in the PATH
		echo You can download it here: https://github.com/kyleconroy/tmx2lua/downloads
		echo.
		pause
		goto :end
	) else (
		echo found !FOUND!
		goto :tmx2lua
	)
)
goto :end

:tmx2lua
echo Checking for outdated .lua files
for %%i in (src\maps\*.tmx) do (
	FOR /F %%j IN ('DIR /B /O:D src\maps\%%~ni.tmx src\maps\%%~ni.lua') DO SET NEWEST=%%~xj
	if "!NEWEST!"==".tmx" (
		tmx2lua src\maps\%%~ni.tmx
	)
)


:end
echo bye!