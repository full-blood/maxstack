macroScript MaxStack_OpenRenderoutput
    category:"MaxStack" 
    tooltip:"Open Renderoutput folder"
    buttonText:"Open Renderoutput folder"
(
	filename = (substring maxFileName 1 (maxFileName.count-4))
	pathfolder = @"L:\7-Postproduction\Renderoutput\"+filename
	pathfolder = substituteString pathfolder " " "_"
	pathfolder = substituteString pathfolder "&" ""

	if (doesDirectoryExist pathfolder != true) then
	(
		shellLaunch "L:\\7-Postproduction\\Renderoutput\\" ""
	)else
	(
-- 		--shellLaunch "explorer.exe" pathfolder
		shellLaunch pathfolder ""
	)
)