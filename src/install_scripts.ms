-- clearListener()
print "install maxstack menu..."

-- Temp folder et user macros
tempDir = GetDir #temp
userMacroDir = GetDir #userMacros

-- Exceptions : chemins spéciaux
maxstackMNXPath = "C:\\Users\\" + sysInfo.username + "\\Autodesk\\3ds Max 2026\\User Settings\\MaxStack.mnx"
maxstackLoaderPath = "C:\\Users\\" + sysInfo.username + "\\AppData\\Local\\Autodesk\\3dsMax\\2026 - 64bit\\ENU\\scripts\\startup\\MaxStack_loader.ms"

-- Copie explicite des fichiers spéciaux AVANT la boucle générique
if doesFileExist (tempDir + "\\MaxStack.mnx") then (
    if doesFileExist maxstackMNXPath then deleteFile maxstackMNXPath
    (dotNetClass "System.IO.File").Copy (tempDir + "\\MaxStack.mnx") maxstackMNXPath
    format "copied MaxStack.mnx to %\n" maxstackMNXPath
)

if doesFileExist (tempDir + "\\MaxStack_loader.ms") then (
    if doesFileExist maxstackLoaderPath then deleteFile maxstackLoaderPath
    (dotNetClass "System.IO.File").Copy (tempDir + "\\MaxStack_loader.ms") maxstackLoaderPath
    format "copied MaxStack_loader.ms to %\n" maxstackLoaderPath
)

-- Boucle générique pour les autres fichiers (.ms, .mcr, .py) vers userMacros
for f in getFiles (tempDir + "\\*.*") do (
    local fname = getFilenameFile f   -- nom sans extension
    local ext   = getFilenameType f   -- extension avec le point

    -- Exclure les fichiers spéciaux déjà traités
    local fullname = fname + ext
    if fullname == "MaxStack.mnx"      then continue
    if fullname == "MaxStack_loader.ms" then continue
    if fullname == "install_scripts.ms" then continue
    if fullname == "mzp.run"            then continue

    if (ext == ".ms" or ext == ".mcr" or ext == ".py") then (
        local dst = userMacroDir + "\\" + fullname
        if doesFileExist dst then (
            format "remove existing file %...\n" dst
            deleteFile dst
        )
        (dotNetClass "System.IO.File").Copy f dst
        format "copied % to %\n" f dst
    )
)

print "run the macro, to install it..."