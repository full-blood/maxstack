@echo off
@REM ====================================================
@REM Final MaxStack MZP Builder (Optimise, Corrige & Auto-Version)
@REM ====================================================
setlocal EnableDelayedExpansion

:: --- Config ---
set "repodir=%~dp0"
set "srcdir=%~dp0src"
set "outdir=%~dp0MAXScript_ZIP_Package"
set "base=MaxStack"
set count=1

:: --- Create output folder if needed ---
if not exist "%outdir%" mkdir "%outdir%"

:: --- Lecture et Auto-Increment de la version ---
set "versionfile=%repodir%version.txt"
if not exist "%versionfile%" (
    > "%versionfile%" echo 1.0.0
    echo version.txt cree avec valeur 1.0.0
)
set /p currentver=<"%versionfile%"

:: Securite : retire les espaces invisibles potentiels
set "currentver=%currentver: =%"

:: Decoupage de la version (format attendu X.Y.Z)
for /f "tokens=1,2,3 delims=." %%a in ("%currentver%") do (
    set major=%%a
    set minor=%%b
    set patch=%%c
)
:: Calcul de la prochaine version
set /a nextpatch=patch + 1
set "nextver=%major%.%minor%.%nextpatch%"

echo.
echo ============================================
echo Version actuelle : %currentver%
echo ============================================
set /p dobump="Passer a la version %nextver% avant de builder ? (o/n) : "
if /I "%dobump%"=="o" (
    set "currentver=%nextver%"
    > "%versionfile%" echo !currentver!
    echo Version mise a jour : !currentver!
) else (
    echo On conserve la version : %currentver%
)
echo.

:: --- Copie version.txt vers outdir pour inclusion dans le MZP ---
copy /Y "%versionfile%" "%outdir%\version.txt" >nul

:: --- Generate mzp.run ---
set "runfile=%outdir%\mzp.run"

> "%runfile%" echo name "MZP Plugin"
>>"%runfile%" echo version %currentver%
>>"%runfile%" echo.
>>"%runfile%" echo extract to $temp\MaxStack_Setup
>>"%runfile%" echo run "$temp\MaxStack_Setup\install_scripts.ms"
>>"%runfile%" echo drop "$temp\MaxStack_Setup\install_scripts.ms"

echo mzp.run generated.

:: --- Generate install_scripts.ms dynamically ---
set "installfile=%outdir%\install_scripts.ms"

> "%installfile%" echo -- clearListener()
>>"%installfile%" echo print "install maxstack menu..."
>>"%installfile%" echo.
>>"%installfile%" echo tempDir = (GetDir #temp) + "\\MaxStack_Setup\\"
>>"%installfile%" echo userMacroDir = GetDir #userMacros
>>"%installfile%" echo startupDir = GetDir #userStartupScripts
>>"%installfile%" echo scriptsDir = GetDir #userScripts
>>"%installfile%" echo.
>>"%installfile%" echo -- Chemins cibles securises
>>"%installfile%" echo maxstackMNXPath     = "C:\\Users\\" + sysInfo.username + "\\Autodesk\\3ds Max 2026\\User Settings\\MaxStack.mnx"
>>"%installfile%" echo maxstackLoaderPath  = startupDir + "\\MaxStack_loader.ms"
>>"%installfile%" echo maxstackVersionPath = scriptsDir + "\\MaxStack\\version.txt"
>>"%installfile%" echo.
>>"%installfile%" echo fn safeCopy src dst = (
>>"%installfile%" echo     if doesFileExist src then (
>>"%installfile%" echo         local dstDir = getFilenamePath dst
>>"%installfile%" echo         if not doesFileExist dstDir then makeDir dstDir
>>"%installfile%" echo         if doesFileExist dst then deleteFile dst
>>"%installfile%" echo         (dotNetClass "System.IO.File").Copy src dst
>>"%installfile%" echo         format "copied %% to %%\n" src dst
>>"%installfile%" echo     ) else (
>>"%installfile%" echo         format "WARNING: not found: %%\n" src
>>"%installfile%" echo     )
>>"%installfile%" echo )
>>"%installfile%" echo.
>>"%installfile%" echo safeCopy (tempDir + "MaxStack.mnx")       maxstackMNXPath
>>"%installfile%" echo safeCopy (tempDir + "MaxStack_loader.ms")  maxstackLoaderPath
>>"%installfile%" echo safeCopy (tempDir + "version.txt")         maxstackVersionPath
>>"%installfile%" echo.
>>"%installfile%" echo genericFiles = #(

set first=1
for %%F in ("%srcdir%\*") do (
    set "fname=%%~nxF"
    set "ext=%%~xF"
    if /I not "!fname!"=="install_scripts.ms" (
    if /I not "!fname!"=="mzp.run" (
    if /I not "!fname!"=="MaxStack.mnx" (
    if /I not "!fname!"=="MaxStack_loader.ms" (
    if /I not "!fname!"=="version.txt" (
    if /I not "!ext!"==".bak" (
    if /I not "!ext!"==".tmp" (
    if /I not "!fname!"=="Thumbs.db" (
        if !first!==1 (
            >>"%installfile%" echo     "!fname!"
            set first=0
        ) else (
            >>"%installfile%" echo     ,"!fname!"
        )
    ))))))))
)

>>"%installfile%" echo )
>>"%installfile%" echo.
>>"%installfile%" echo for fname in genericFiles do (
>>"%installfile%" echo     safeCopy (tempDir + fname) (userMacroDir + "\\" + fname)
>>"%installfile%" echo )
>>"%installfile%" echo.
>>"%installfile%" echo print "run the macro, to install it..."
>>"%installfile%" echo messageBox "Maxstack v%currentver% installed." title:"Maxstack installed."
>>"%installfile%" echo print "-- END --"

echo install_scripts.ms generated.

:: --- Determine next incremental MZP filename ---
:loop
set num=00%count%
set num=%num:~-3%
set "mzpfile=%outdir%\%base%_%num%.mzp"
if exist "%mzpfile%" (
    set /a count+=1
    goto loop
)

:: --- Build MZP ---
:: Etape 1 : fichiers src
pushd "%srcdir%"
"%ProgramFiles%\7-Zip\7z.exe" a -tzip "%mzpfile%" *
popd

:: Etape 2 : mzp.run + install_scripts.ms + version.txt depuis outdir
pushd "%outdir%"
"%ProgramFiles%\7-Zip\7z.exe" a -tzip "%mzpfile%" mzp.run install_scripts.ms version.txt
popd

:: --- Copie a la racine du repo ---
copy /Y "%mzpfile%" "%repodir%MaxStack.mzp" >nul
echo MaxStack.mzp copie a la racine.

echo.
echo ============================================
echo  Build termine : MaxStack v%currentver%
echo  Archive : %mzpfile%
echo ============================================
echo.

:: --- Git push ---
set /p dopublish="Publier sur GitHub (git add/commit/push) ? (o/n) : "
if /I not "%dopublish%"=="o" goto done

pushd "%repodir%"
git add .
git commit -m "release v%currentver%"
git push
popd

echo.
echo Pushed. Cree la Release sur GitHub :
echo https://github.com/full-blood/maxstack/releases/new
echo Tag : v%currentver%
echo Asset a uploader : MaxStack.mzp

:done
echo.
pause