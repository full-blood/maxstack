-- clearListener()
print "install maxstack menu..."

tempDir = (GetDir #temp) + "\\MaxStack_Setup\\"
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
    ,"MaxStack_PasteAsset.mcr"
)

for fname in genericFiles do (
    safeCopy (tempDir + fname) (userMacroDir + "\\" + fname)
)

print "run the macro, to install it..."
messageBox "Maxstack v1.0.6 installed." title:"Maxstack installed."
print "-- END --"
