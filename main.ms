local toolDir = (getDir #userScripts) + "/MaxStack"
fileIn (toolDir + "/update/update.ms")

checkForUpdate toolDir

messageBox "MaxStack lancé."
