setlocal EnableDelayedExpansion
echo off
cls
echo.

echo Checking for outdated .lua files
for %%i in (src\maps\*.tmx) do (
	FOR /F %%j IN ('DIR /B /O:D src\maps\%%~ni.tmx src\maps\%%~ni.lua') DO SET NEWEST=%%~xj
	if "!NEWEST!"==".tmx" (
		tmx2lua src\maps\%%~ni.tmx
	)
)


:end
echo bye!