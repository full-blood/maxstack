-- clearListener()
print "install maxstack menu..."

tempDir = getFilenamePath (getSourceFileName())
userMacroDir = GetDir #userMacros
startupDir = GetDir #userStartupScripts
scriptsDir = GetDir #userScripts

-- Chemins cibles securises
maxstackMNXPath     = "C:\\Users\\" + sysInfo.username + "\\Autodesk\\3ds Max 2026\\User Settings\\MaxStack.mnx"
maxstackLoaderPath  = startupDir + "\\MaxStack_loader.ms"
maxstackVersionPath = scriptsDir + "\\MaxStack\\version.txt"

fn safeCopy src dst = (
    if doesFileExist src then (
        local dstDir = getFilenamePath dst
        if not doesFileExist dstDir then makeDir dstDir
        if doesFileExist dst then deleteFile dst
        (dotNetClass "System.IO.File").Copy src dst
        format "copied % to %\n" src dst
    ) else (
        format "WARNING: not found: %\n" src
    )
)

safeCopy (tempDir + "MaxStack.mnx")       maxstackMNXPath
safeCopy (tempDir + "MaxStack_loader.ms")  maxstackLoaderPath
safeCopy (tempDir + "version.txt")         maxstackVersionPath

genericFiles = #(
    "MaxStack-MaxStack_About.mcr"
    ,"MaxStack-MaxStack_Menu.mcr"
    ,"MaxStack-MaxStack_Mirror.mcr"
    ,"MaxStack-MaxStack_MoveHalf.mcr"
    ,"MaxStack_MaxStack_PasteClipboardImg.ms"
    ,"MaxStack_PasteAsset.mcr"
)

for fname in genericFiles do (
    local dstPath = userMacroDir + "\\" + fname
    safeCopy (tempDir + fname) dstPath

    -- On evalue (recharge) les scripts pour les activer sans redemarrer 3ds Max
    local ext = toLower (getFilenameType fname)
    if ext == ".mcr" or ext == ".ms" then (
        try ( fileIn dstPath ) catch ( format "Erreur d'evaluation sur %\n" fname )
    )
)

-- -----------------------------------------------
-- Rechargement du Menu (3ds Max 2025+)
-- -----------------------------------------------
try (
    local menuMgr = maxops.GetICuiMenuMgr()
    menuMgr.LoadConfiguration maxstackMNXPath
    print "Menu charge avec succes "
) catch (
    format "Erreur lors du chargement du menu : %\n" (getCurrentException())
)

print "Installation terminée."
messageBox "Maxstack v1.0.12 installée avec succès "Maxstack installe"
print "-- END --"
