@echo off
@REM ====================================================
@REM Final MaxStack MZP Builder
@REM ====================================================
setlocal EnableDelayedExpansion

:: --- Config ---
set srcdir=%~dp0src
set outdir=%~dp0MAXScript_ZIP_Package
set base=MaxStack
set count=1

:: --- Create output folder if needed ---
if not exist "%outdir%" mkdir "%outdir%"

:: --- Lecture version (cree version.txt si absent) ---
set versionfile=%srcdir%\version.txt
if not exist "%versionfile%" (
    echo 1.0.0> "%versionfile%"
    echo version.txt cree avec valeur 1.0.0
)
set /p currentver=<"%versionfile%"
echo Version actuelle : %currentver%

:: --- Generate mzp.run ---
set runfile=%outdir%\mzp.run

echo name "MZP Plugin" > "%runfile%"
echo version %currentver% >> "%runfile%"
echo. >> "%runfile%"
echo copy MaxStack.mnx to $temp >> "%runfile%"
echo copy MaxStack_loader.ms to $temp >> "%runfile%"
echo copy version.txt to $temp >> "%runfile%"

for %%F in ("%srcdir%\*") do (
    set fname=%%~nxF
    set ext=%%~xF
    if /I not "!fname!"=="install_scripts.ms" (
    if /I not "!fname!"=="mzp.run" (
    if /I not "!fname!"=="MaxStack.mnx" (
    if /I not "!fname!"=="MaxStack_loader.ms" (
    if /I not "!fname!"=="version.txt" (
    if /I not "!ext!"==".bak" (
    if /I not "!ext!"==".tmp" (
    if /I not "!fname!"=="Thumbs.db" (
        echo copy !fname! to $temp >> "%runfile%"
    ))))))))
)

echo run "install_scripts.ms" >> "%runfile%"
echo mzp.run generated.

:: --- Generate install_scripts.ms dynamically ---
set installfile=%outdir%\install_scripts.ms

echo -- clearListener() > "%installfile%"
echo print "install maxstack menu..." >> "%installfile%"
echo. >> "%installfile%"
echo tempDir = GetDir #temp >> "%installfile%"
echo userMacroDir = GetDir #userMacros >> "%installfile%"
echo userScriptsDir = GetDir #userScripts >> "%installfile%"
echo. >> "%installfile%"
echo maxstackMNXPath     = "C:\\Users\\" + sysInfo.username + "\\Autodesk\\3ds Max 2026\\User Settings\\MaxStack.mnx" >> "%installfile%"
echo maxstackLoaderPath  = "C:\\Users\\" + sysInfo.username + "\\AppData\\Local\\Autodesk\\3dsMax\\2026 - 64bit\\ENU\\scripts\\startup\\MaxStack_loader.ms" >> "%installfile%"
echo maxstackVersionPath = userScriptsDir + "\\MaxStack\\version.txt" >> "%installfile%"
echo. >> "%installfile%"
echo fn safeCopy src dst = ( >> "%installfile%"
echo     if doesFileExist src then ( >> "%installfile%"
echo         local dstDir = getFilenamePath dst >> "%installfile%"
echo         if not doesFileExist dstDir then makeDir dstDir >> "%installfile%"
echo         if doesFileExist dst then deleteFile dst >> "%installfile%"
echo         (dotNetClass "System.IO.File").Copy src dst >> "%installfile%"
echo         format "copied %% to %%\n" src dst >> "%installfile%"
echo     ) else ( >> "%installfile%"
echo         format "WARNING: not found: %%\n" src >> "%installfile%"
echo     ) >> "%installfile%"
echo ) >> "%installfile%"
echo. >> "%installfile%"
echo safeCopy (tempDir + "\\MaxStack.mnx")       maxstackMNXPath >> "%installfile%"
echo safeCopy (tempDir + "\\MaxStack_loader.ms")  maxstackLoaderPath >> "%installfile%"
echo safeCopy (tempDir + "\\version.txt")         maxstackVersionPath >> "%installfile%"
echo. >> "%installfile%"
echo genericFiles = #( >> "%installfile%"

set first=1
for %%F in ("%srcdir%\*") do (
    set fname=%%~nxF
    set ext=%%~xF
    if /I not "!fname!"=="install_scripts.ms" (
    if /I not "!fname!"=="mzp.run" (
    if /I not "!fname!"=="MaxStack.mnx" (
    if /I not "!fname!"=="MaxStack_loader.ms" (
    if /I not "!fname!"=="version.txt" (
    if /I not "!ext!"==".bak" (
    if /I not "!ext!"==".tmp" (
    if /I not "!fname!"=="Thumbs.db" (
        if !first!==1 (
            echo     "!fname!" >> "%installfile%"
            set first=0
        ) else (
            echo     ,"!fname!" >> "%installfile%"
        )
    ))))))))
)

echo ) >> "%installfile%"
echo. >> "%installfile%"
echo for fname in genericFiles do ( >> "%installfile%"
echo     safeCopy (tempDir + "\\" + fname) (userMacroDir + "\\" + fname) >> "%installfile%"
echo ) >> "%installfile%"
echo. >> "%installfile%"
echo print "run the macro, to install it..." >> "%installfile%"
echo messageBox "Maxstack v%currentver% installed." title:"Maxstack installed." >> "%installfile%"
echo print "-- END --" >> "%installfile%"

echo install_scripts.ms generated.

:: --- Determine next incremental MZP filename ---
:loop
set num=00%count%
set num=%num:~-3%
set mzpfile=%outdir%\%base%_%num%.mzp
if exist "%mzpfile%" (
    set /a count+=1
    goto loop
)

:: --- Build MZP ---
pushd "%srcdir%"
"%ProgramFiles%\7-Zip\7z.exe" a -tzip "%mzpfile%" *
popd

pushd "%outdir%"
"%ProgramFiles%\7-Zip\7z.exe" a -tzip "%mzpfile%" mzp.run install_scripts.ms
popd

:: --- Copie a la racine du repo ---
copy /Y "%mzpfile%" "%~dp0MaxStack.mzp" >nul
echo MaxStack.mzp copie a la racine.

echo.
echo ============================================
echo  Build termine : MaxStack v%currentver%
echo  Archive : %mzpfile%
echo ============================================
echo.

:: --- Git push ---
set /p dopublish=Publier sur GitHub (git add/commit/push) ? (o/n) :
if /I not "%dopublish%"=="o" goto done

set /p commitmsg=Message de commit :

pushd "%~dp0"
git add .
git commit -m "%commitmsg%"
git push
popd

echo.
echo Pushed. Cree la Release sur GitHub :
echo https://github.com/TON_USERNAME/TON_REPO/releases/new
echo Uploade MaxStack.mzp comme asset de la release.

:done
echo.
pause