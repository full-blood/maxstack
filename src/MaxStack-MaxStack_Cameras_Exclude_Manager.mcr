/*
================================================================================
Script Name: MaxStack_Cameras_Exclude_Manager
Category: MaxStack
Description: Gestionnaire d'exclusion/inclusion pour toutes les caméras de la
             scène.
================================================================================
*/

macroScript MaxStack_Cameras_Exclude_Manager
    category:"MaxStack" 
    toolTip:"Cameras Exclude Manager"
    buttonText:"Cameras Exclude Manager"
(

-- for L in cameras where isProperty L #excludeListIncludeMod do (print L.excludeList)

-- exclude selection for all other cameras

camera_list = #()
exludeObj_list = #()
addObj_list = #()
global storeSel = #()
global selected_cam

try(DestroyDialog cam_Incl)catch()
rollout cam_Incl "Include/Exclude object(s) to cameras" width:660 height:470
(
	multiListBox 'lbx1' "camera(s) list : " pos:[20,20] width:300 height:25 align:#left
	multiListBox 'lbx3' "exclude list :" pos:[340,20] width:300 height:25 align:#left
	button 'btn7' "get selected camera(s)" pos:[20,380] width:139 height:29 align:#left
	button 'btn13' "get camera from viewport" pos:[175,380] width:139 height:29 align:#left
	
	label 'lb_1' "List item(s) :" pos:[340,380] width:100 height:29 align:#left
	button 'btn12' "select items" pos:[430,380] width:100 height:29 align:#left
	button 'btn8' "delete selected" pos:[540,380] width:100 height:29 align:#left
	
	label 'lb_2' "Scene object(s) :" pos:[340,420] width:100 height:29 align:#left
	button 'btn9' "add selected" pos:[430,420] width:100 height:29 align:#left
	button 'btn11' "delete selected" pos:[540,420] width:100 height:29 align:#left
	
	button 'btn_help' "Help" pos:[20,420] width:80 height:29 align:#left
	button 'btn6' "store selection" pos:[115,420] width:199 height:29 align:#left
	timer tmr_refreshAfterUndo interval:100 active:false
	
	fn updateExcludeList =
	(
		sel_item = lbx1.selection
		sel_item = sel_item as Array
		if sel_item.count == 0 do (
			lbx3.items = #()
			return false
		)
		selected_cam = getNodeByName lbx1.items[sel_item[1]]
		if selected_cam == undefined do (
			lbx3.items = #()
			return false
		)
		exludeObj_list = #()
		for i in selected_cam.excludeList do (
			try(appendIfUnique exludeObj_list (i.name as string))catch(print "object does'nt exist anymore")
		)
		sort exludeObj_list
		lbx3.items = exludeObj_list
	)
	fn selectCameraInList camNode =
	(
		if camNode == undefined do return false
		if superclassof camNode != camera do return false
		
		local camIndex = findItem lbx1.items camNode.name
		if camIndex == 0 do return false
		
		lbx1.selection = #(camIndex)
		updateExcludeList()
		true
	)
	fn refreshAfterUndoRedo =
	(
		try(tmr_refreshAfterUndo.active = true)catch()
	)
	on cam_Incl open do (
		camera_list = for o in cameras where classof o != targetobject collect o.name
		lbx1.items = camera_list
		try(callbacks.removeScripts id:#MaxStackCameraExcludeRefresh)catch()
		try(callbacks.addScript #sceneUndo "try(cam_Incl.refreshAfterUndoRedo())catch()" id:#MaxStackCameraExcludeRefresh)catch()
		try(callbacks.addScript #sceneRedo "try(cam_Incl.refreshAfterUndoRedo())catch()" id:#MaxStackCameraExcludeRefresh)catch()
	)
	on cam_Incl close do (
		try(callbacks.removeScripts id:#MaxStackCameraExcludeRefresh)catch()
	)
	on tmr_refreshAfterUndo tick do (
		tmr_refreshAfterUndo.active = false
		try(updateExcludeList())catch()
	)
	on btn2 picked obj do (
		 if isValidNode obj do print (obj.name as string)
	)
	on lbx1 doubleClicked nameIndex do (
		max select none
		select (getNodeByName lbx1.items[nameIndex])
	)
	on lbx3 doubleClicked nameIndex do (
		max select none
		select (getNodeByName lbx3.items[nameIndex])
	)
	on lbx1 selectionEnd do (
		updateExcludeList()
-- 		sel_item = lbx1.selection
-- 		sel_item = sel_item as Array
-- 		selected_cam = getNodeByName lbx1.items[sel_item[1]]
-- 		exludeObj_list = #()
-- 		for i in selected_cam.excludeList do (
-- 			try(appendIfUnique exludeObj_list (i.name as string))catch(print "object does'nt exist anymore")
-- 		)
-- 		sort exludeObj_list
-- 		lbx3.items = exludeObj_list
	)
	-- add objects to exclusion list
	on btn9 pressed do (
		addObj_list = for o in selection collect o
		for i in lbx1.selection do (
			selected_cam = getNodeByName lbx1.items[i]
			selected_cam.overrideVisibility = on
			selected_cam.excludeListIncludeMod = off
			for o in addObj_list do (
				if (classof o != CoronaCam) do (
					if (classof o != Targetobject) do (
						appendIfUnique (selected_cam.excludeList) o
					)
				)
			)
			exludeObj_list = #()
			tm = selected_cam.excludeList as array
			for i in selected_cam.excludeList do (
				try(append exludeObj_list (i.name as string))catch(print "object does'nt exist anymore")
			)
			lbx3.items = exludeObj_list
		)
	)
	-- delete list obj
	on btn8 pressed do (
		undo "Delete selected exclude list items" on (
			objToDelete = (lbx3.items  as array)
			sel_item = lbx1.selection
			sel_item = sel_item as Array
			if sel_item.count > 0 do (
				selected_cam = getNodeByName lbx1.items[sel_item[1]]
				selIndices = lbx3.selection as array
				for idx = selIndices.count to 1 by -1 do (
					selIdx = selIndices[idx]
					deleteItem objToDelete selIdx
					deleteItem selected_cam.excludeList selIdx
				)
				lbx3.items = objToDelete
			)
		)
	)
	-- delete scene obj
	on btn11 pressed do (
		undo "Delete selected scene objects from exclude list" on (
			sel_item = lbx1.selection as Array
			if sel_item.count > 0 do selected_cam = getNodeByName lbx1.items[sel_item[1]]
			
			if selected_cam != undefined do (
				selectionObjects = for o in selection collect o
				exludeObj_list = selected_cam.excludeList
				deleteObj_list = #()
				
				for o in selectionObjects do (
					idx = findItem exludeObj_list o
					if idx > 0 do appendIfUnique deleteObj_list idx
				)
				rev_deleteObj_list = for i = deleteObj_list.count to 1 by -1 collect deleteObj_list[i]
				for i in rev_deleteObj_list do (
					try(deleteItem exludeObj_list i)catch()
				)
			)
		)
		
		updateExcludeList()
	)
	on btn7 pressed do (
		select_cameras = #()
		for L in selection where superclassof L == camera do (
			append select_cameras ((findItem lbx1.items L.name)as integer)
		)
		lbx1.selection = select_cameras
		if select_cameras.count == 1 then (
			lbx1.selectionEnd()
		)
		
	)
	on btn13 pressed do (
		pickPoint prompt:"Click the viewport to read its camera."
		viewportCamera = viewport.getCamera()
		if not (selectCameraInList viewportCamera) do (
			messageBox "The clicked viewport is not a camera view, or the camera is not in the list." title:"Camera From Viewport"
		)
	)
	on btn6 pressed do (
		if (substring btn6.text 1 10) != "add stored" then (
			storeSel = #()
			for o in selection where superclassof o != camera do (
				append storeSel o
			)
			btn6.text = ("add stored objects ("+(storeSel.count as string)+")")
		)else if storeSel.count != 0 then (
			for i in lbx1.selection do (
				selected_cam = getNodeByName lbx1.items[i]
				selected_cam.overrideVisibility = on
				selected_cam.excludeListIncludeMod = off
				for o in storeSel do (
					print o.name
					if (classof o != CoronaCam) do (
						if (classof o != Targetobject) do (
							appendIfUnique (selected_cam.excludeList) o
						)
					)
				)
				exludeObj_list = #()
				tm = selected_cam.excludeList as array
				for i in selected_cam.excludeList do (
					try(append exludeObj_list (i.name as string))catch(print "object does'nt exist anymore")
				)
				lbx3.items = exludeObj_list
			)
		)
	)
	on btn6 rightclick do (
		btn6.text = "store selection"
	)
	on lbx3 rightClick do (
		max select none
		for o in lbx3.selection do (
			selectmore (getNodeByName lbx3.items[o])
		)
	)
	on btn12 pressed do (
		max select none
		for o in lbx3.selection do (
			selectmore (getNodeByName lbx3.items[o])
		)
	)
	-- HELP DIALOG LOGIC
	on btn_help pressed do (
		try(DestroyDialog help_cam_Incl)catch()
		rollout help_cam_Incl "Help: Cameras Exclude Manager" width:750 height:750
		(
			label help_text "Description :" pos:[15,15] width:720 height:700 readOnly:true
			button btn_ok "OK" pos:[375,710] width:60 height:25

			on help_cam_Incl open do (
				help_text.text = "This tool manages the render exclusion list for cameras in the current 3ds Max scene.\n\n" \
								+ "--------------------------------------------------------\n\n" \
								+ "MAIN PANELS\n\n" \
								+ "- camera(s) list (left):\nLists all scene cameras, excluding standard target objects.\n\n" \
								+ "- exclude list (right):\nShows the objects currently excluded for the selected camera.\n\n" \
								+ "--------------------------------------------------------\n\n" \
								+ "MANAGEMENT BUTTONS\n\n" \
								+ "- get selected camera(s):\nSelects in the left list the cameras currently selected in the scene.\n\n" \
								+ "- get camera from viewport:\nClick a viewport, then the tool checks whether that viewport is a camera view. If it is, the matching camera is selected in the left list.\n\n" \
								+ "- store selection:\nStores the current scene object selection. The button text changes to show how many objects are stored. Right-click this button to clear the stored selection.\n\n" \
								+ "- add selected (Scene object(s)):\nAdds the selected scene objects to the exclusion list of the selected cameras.\n\n" \
								+ "- select items (List item(s)):\nSelects in the scene the objects selected in the exclude list.\n\n" \
								+ "- delete selected (List item(s)):\nRemoves the selected list entries from the active camera exclusion list. This action supports Undo.\n\n" \
								+ "- delete selected (Scene object(s)):\nRemoves the selected scene objects from the active camera exclusion list when they are present. This action supports Undo.\n\n" \
								+ "--------------------------------------------------------\n\n" \
								+ "QUICK ACTIONS\n\n" \
								+ "- Double-click a camera:\nSelects that camera in the scene and updates the exclude list.\n\n" \
								+ "- Double-click an excluded object:\nSelects that object in the scene.\n\n" \
								+ "- Right-click the exclude list:\nSelects all highlighted exclude-list objects in the scene."
			)

			on btn_ok pressed do (
				DestroyDialog help_cam_Incl
			)
		)
		CreateDialog help_cam_Incl
	)
)

CreateDialog cam_Incl
)
