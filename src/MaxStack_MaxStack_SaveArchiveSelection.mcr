macroScript MaxStack_SaveArchiveSelection
category:"MaxStack"
buttonText:"Archive selection"
tooltip:"Save selection in 1_Archive with timestamp and preview"
(

--pre_filename = (maxFilePath+"1_Archive\\"+maxFileName) as string

Char_1 = (substring maxFileName 1 2)
Char_2 = (substring maxFileName 1 4)
Char_7 = (substring maxFileName 7 1)
Char_sub = 1
global year
global month
global day
global hour
global filename
global sub_filename
global selectedObjects = selection as array


if Char_1 == "26" OR Char_1 == "25" OR Char_1 == "24" OR Char_1 == "23" OR Char_1 == "22" then (
	if (substring maxFileName 7 1) == "_" then (
		Char_sub = 7
	)
)
if Char_2 == "2026" OR Char_2 == "2025" OR Char_2 == "2024" OR Char_2 == "2023" OR Char_2 == "2022" then (
	if (substring maxFileName 9 1) == "_" then (
		messageBox "D"
		Char_sub = 9
	)
)

pre_filename = (substring maxFileName Char_sub maxFileName.count)
	
date = getLocalTime()
year = date[1] as string

if date[2] < 10 then (month = "0"+date[2] as string)else(month = date[2] as string)
if date[4] < 10 then (day = "0"+date[4] as string)else(day = date[4] as string)
if date[5] < 10 then (hour = "0"+date[5] as string)else(hour = date[5] as string)
if date[6] < 10 then (hour = hour+"0"+(date[6] as string))else(hour = hour+(date[6] as string))
filename = (year as string)+(month  as string)+(day as string)+(hour as string)+(pre_filename as string)
try(filename = substituteString filename ".max" "_")catch(messageBox "nothing selected...")
sub_filename = (maxFilePath+"1_Archive\\"+filename) as string
edittextStr = "save as :   \\1_Archive\\"+filename
edittextStr = substituteString edittextStr ".max" ""
		
HiddenDosCommand (maxFilePath+"1_Archive\\")

IsolateSelection.EnterIsolateSelectionMode()
if (viewport.numViews >= 2) then (
	max tool maximize
)
else (print viewport.numViews)
global ViewportType_encours = #(viewport.getType(),viewport.GetRenderLevel())
max vpt persp user
viewport.SetRenderLevel #smoothhighlights 
max zoomext sel
max select none
		
try(DestroyDialog ArchiveSaveAsSelection) catch()
rollout ArchiveSaveAsSelection "Save as ..." height:70 width:600
(
	edittext txtfld1 edittextStr text:(try(selectedObjects[1].layer.name+"_"+selectedObjects[1].name)catch(selectedObjects[1].name))
	button btn1 "ok" height:18 width:100 align:#center offset:[0,10]
	
	on btn1 pressed do (
-- 		messageBox (maxFilePath+"1_Archive\\"+txtfld1.text) as string
		
		txtfld1_converted = txtfld1.text
		txtfld1_converted = substituteString txtfld1_converted "\\" ""
		txtfld1_converted = substituteString txtfld1_converted "/" ""
		txtfld1_converted = substituteString txtfld1_converted ":" ""
		txtfld1_converted = substituteString txtfld1_converted "*" ""
		txtfld1_converted = substituteString txtfld1_converted "?" ""
		txtfld1_converted = substituteString txtfld1_converted "\"" ""
		txtfld1_converted = substituteString txtfld1_converted "<" ""
		txtfld1_converted = substituteString txtfld1_converted ">" ""
		txtfld1_converted = substituteString txtfld1_converted "|" ""
		
		saveNodes selectedObjects (sub_filename+txtfld1_converted+".max") -- useNewFile:false
		
		global viewport_capture = gw.getViewportDib()

		if viewport_capture != undefined then
		(
			viewport_capture.filename = (sub_filename+txtfld1_converted+".jpg")
			save viewport_capture
			close viewport_capture
		)
		else
		(
			format "Error: Failed to capture viewport bitmap.\n"
		)
		
		try(destroyDialog ArchiveSaveAsSelection)catch()
		
		max select all
		max tool maximize
		viewport.setType ViewportType_encours[1]
		viewport.SetRenderLevel ViewportType_encours[2]
		IsolateSelection.ExitIsolateSelectionMode()
	)
)
CreateDialog ArchiveSaveAsSelection
-- if queryBox ("save as : \\1_Archive\\"+(filename as string)) then (
-- 	saveNodes selectedObjects sub_filename -- useNewFile:false
-- )
)
