-- clearListener() 
print "install maxstack menu..." 
 
tempDir = GetDir #temp 
userMacroDir = GetDir #userMacros 
filesToCopy = #( 
    "MaxStack.mnx", 
    "MaxStack_loader.ms", 
) 
for fname in filesToCopy do ( 
    local src = tempDir + "\\" + fname 
    local dst = userMacroDir + "\\" + fname 
 
    if doesFileExist dst then ( 
        deleteFile dst 
        print "OK" 
    ) 
 
    dotNetClass "System.IO.File".Copy src dst 
    format "copied \n" src dst 
) 
 
print "run the macro, to install it..." 
messageBox "Maxstack scripts installed." title:"Maxstack installed." 
print "-- END --" 
