macroScript MaxStack_BatchRender
    category:"MaxStack" 
    tooltip:"Update Batch Render with all cameras"
    buttonText:"Setup batch render"
(

--collect cameras and sort by name
fn compareNames str1 str2 = stricmp str1.name str2.name
Cams = for Cam in cameras where (superclassof Cam == camera) collect Cam
qSort Cams compareNames
	
-- print batchRenderMgr.numViews

if Cams.count > 0 then (
	-- save existing camera's state
	getViewOFF = #()
	getViewOverride = #(#(),#(),#(),#(),#(),#())
	for i = 1 to batchRenderMgr.numViews do (
		if (batchRenderMgr.GetView i).enabled == false then (
			try(append getViewOFF ((batchRenderMgr.GetView i).camera).name)catch()
		)
		if (batchRenderMgr.GetView i).overridePreset == true then (
			append getViewOverride[1] ((batchRenderMgr.GetView i).camera).name
			append getViewOverride[2] (batchRenderMgr.GetView i).startFrame
			append getViewOverride[3] (batchRenderMgr.GetView i).endFrame
			append getViewOverride[4] (batchRenderMgr.GetView i).width
			append getViewOverride[5] (batchRenderMgr.GetView i).height
			append getViewOverride[6] (batchRenderMgr.GetView i).pixelAspect
		)
	)
	
	-- reset all views
	for i = 1 to batchRenderMgr.numViews do (
		batchRenderMgr.DeleteView 1
	)
	-- create a view for each cameras 
	i = 0
	for cam in Cams do (
		i = i+1
		batchRenderMgr.CreateView cam
		(batchRenderMgr.GetView i).name = cam.name
		index = findItem getViewOFF cam.name -- search if camera preview's state exist
		if index != 0 then (
			(batchRenderMgr.GetView i).enabled = false
		)
		overIndex = findItem getViewOverride[1] cam.name -- search if camera preview's override exist
		if overIndex != 0 then (
			(batchRenderMgr.GetView i).overridePreset = true
			(batchRenderMgr.GetView i).startFrame = getViewOverride[2][overIndex]
			(batchRenderMgr.GetView i).endFrame = getViewOverride[3][overIndex]
			(batchRenderMgr.GetView i).width = getViewOverride[4][overIndex]
			(batchRenderMgr.GetView i).height = getViewOverride[5][overIndex]
			(batchRenderMgr.GetView i).pixelAspect = getViewOverride[6][overIndex]
		)
		filename = (substring maxFileName 1 (maxFileName.count-4))
		filepath = "L:\\7-Postproduction\\Renderoutput\\"+filename+"\\"+cam.name
		filepath = substituteString filepath " " "_"
		filepath = substituteString filepath "&" ""
		(batchRenderMgr.GetView i).outputFilename = filepath+"\\"+"render.jpg"
		
		-- create folders
		createfolder = "mkdir "+filepath
			print filepath
		HiddenDosCommand createfolder
		
	)
)

-- reset render element path
re = maxOps.GetCurRenderElementMgr()
for i = 0 to re.NumRenderElements() do (
	re.SetRenderElementFilename i ""
)
--open batch render window
try(xro_hwnd = windows.getChildHWND 0 "Batch Render"
windows.sendMessage xro_hwnd[1] 0x0010 0 0)catch()
actionMan.executeAction -43434444 "4096"

)