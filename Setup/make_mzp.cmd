@echo off
@REM ====================================================
@REM Final MaxStack MZP Builder
@REM mzp.run + install_scripts.ms (from src) at root
@REM ====================================================
setlocal EnableDelayedExpansion

:: --- Config ---
set srcdir=%~dp0src
set outdir=%~dp0MAXScript_ZIP_Package
set base=MaxStack
set count=1

:: --- Create output folder if needed ---
if not exist "%outdir%" mkdir "%outdir%"

:: --- Generate mzp.run ---
set runfile=%outdir%\mzp.run

echo name "MZP Plugin" > "%runfile%"
echo version 0.1 >> "%runfile%"
echo. >> "%runfile%"

:: --- Copy exceptions first ---
echo copy MaxStack.mnx to $temp >> "%runfile%"
echo copy MaxStack_loader.ms to $temp >> "%runfile%"

:: --- Loop over all valid src files and add copy commands ---
for %%F in ("%srcdir%\*") do (
    set fname=%%~nxF
    set ext=%%~xF
    if /I not "!fname!"=="install_scripts.ms" (
    if /I not "!fname!"=="mzp.run" (
    if /I not "!fname!"=="MaxStack.mnx" (
    if /I not "!fname!"=="MaxStack_loader.ms" (
    if /I not "!ext!"==".bak" (
    if /I not "!ext!"==".tmp" (
    if /I not "!fname!"=="Thumbs.db" (
        echo copy !fname! to $temp >> "%runfile%"
    )))))))
)

echo run "install_scripts.ms" >> "%runfile%"
echo mzp.run generated: "%runfile%"

:: --- Copy the real install_scripts.ms from src to outdir ---
copy /Y "%srcdir%\install_scripts.ms" "%outdir%\install_scripts.ms" >nul
echo install_scripts.ms copied to outdir root.

:: --- Determine next incremental MZP filename ---
:loop
set num=00%count%
set num=%num:~-3%
set mzpfile=%outdir%\%base%_%num%.mzp
if exist "%mzpfile%" (
    set /a count+=1
    goto loop
)

:: --- Etape 1 : ajouter les fichiers de src\ a la racine du ZIP ---
pushd "%srcdir%"
"%ProgramFiles%\7-Zip\7z.exe" a -tzip "%mzpfile%" *
popd

:: --- Etape 2 : ajouter mzp.run et install_scripts.ms a la racine du ZIP ---
pushd "%outdir%"
"%ProgramFiles%\7-Zip\7z.exe" a -tzip "%mzpfile%" mzp.run install_scripts.ms
popd

echo.
echo Done: %mzpfile%
echo Contents: all files from src\ + mzp.run + install_scripts.ms at zip root
pause