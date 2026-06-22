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
	button 'btn6' "store selection" pos:[175,380] width:139 height:29 align:#left
	
	label 'lb_1' "List item(s) :" pos:[340,380] width:100 height:29 align:#left
	button 'btn12' "selecte items" pos:[430,380] width:100 height:29 align:#left
	button 'btn8' "delete selected" pos:[540,380] width:100 height:29 align:#left
	
	label 'lb_2' "Scene object(s) :" pos:[340,420] width:100 height:29 align:#left
	button 'btn9' "add selected" pos:[430,420] width:100 height:29 align:#left
	button 'btn11' "delete selected" pos:[540,420] width:100 height:29 align:#left
	
	button 'btn_help' "Help" pos:[20,420] width:80 height:29 align:#left
	
	fn updateExcludeList =
	(
		sel_item = lbx1.selection
		sel_item = sel_item as Array
		selected_cam = getNodeByName lbx1.items[sel_item[1]]
		exludeObj_list = #()
		for i in selected_cam.excludeList do (
			try(appendIfUnique exludeObj_list (i.name as string))catch(print "object does'nt exist anymore")
		)
		sort exludeObj_list
		lbx3.items = exludeObj_list
	)
	on cam_Incl open do (
		camera_list = for o in cameras where classof o != targetobject collect o.name
		lbx1.items = camera_list
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
		objToDelete = (lbx3.items  as array)
		sel_item = lbx1.selection
		sel_item = sel_item as Array
		selected_cam = getNodeByName lbx1.items[sel_item[1]]
		for i in lbx3.selection do (
			selIdx = (lbx3.selection as array)[1]
			deleteItem objToDelete selIdx
			deleteItem selected_cam.excludeList selIdx
			lbx3.items = objToDelete
		)
	)
	-- delete scene obj
	on btn11 pressed do (
		
		selectionObjects = for o in selection collect o
		exludeObj_list = selected_cam.excludeList
		deleteObj_list = #()
		
		for o in selectionObjects do (
			 appendIfUnique deleteObj_list (findItem exludeObj_list o)
		)
		rev_deleteObj_list = for i = deleteObj_list.count to 1 by -1 collect deleteObj_list[i]
		for i in rev_deleteObj_list do (
			try(deleteItem exludeObj_list i)catch()
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
	on btn6 pressed do (
		if (substring btn6.text 1 10) != "add stored" then (
			storeSel = #()
			for o in selection where superclassof L != camera do (
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
		rollout help_cam_Incl "Aide : Gestionnaire d'Exclusion" width:750 height:750
		(
			label help_text "Description :" pos:[15,15] width:720 height:700 readOnly:true
			button btn_ok "OK" pos:[375,710] width:60 height:25

			on help_cam_Incl open do (
				help_text.text = "Ce script MaxScript permet de g rer facilement la liste d'objets exclus du rendu pour les cam ras s lectionn es dans la sc ne 3ds Max. \n\n" \
								+ "--------------------------------------------------------\n\n" \
								+ "PRINCIPAUX PANNEAUX\n\n" \
								+ "- camera(s) list (Gauche) :\nAffiche la liste de toutes les cam ras de la sc ne (sauf les cam ras cibles standard).\n\n" \
								+ "- exclude list (Droite) :\nAffiche les objets actuellement exclus du rendu pour la cam ra s lectionn e dans la liste de gauche.\n\n" \
								+ "--------------------------------------------------------\n\n" \
								+ "BOUTONS DE GESTION\n\n" \
								+ "- get selected camera(s) :\nS lectionne dans la liste de gauche les cam ras actuellement s lectionn es dans la sc ne.\n\n" \
								+ "- store selection :\nM morise les objets s lectionn s dans la sc ne.\n(Le texte du bouton change pour afficher le compte d'objets stock s. Clic Droit pour r initialiser la m moire).\n\n" \
								+ "- add selected (Scene object(s)) :\nAjoute les objets s lectionn s dans la sc ne   la liste d'exclusion des cam ras s lectionn es dans la liste de gauche.\n\n" \
								+ "- selecte items (List item(s)) :\nS lectionne dans la sc ne les objets qui sont s lectionn s dans la liste d'exclusion (Droite).\n\n" \
								+ "- delete selected (List item(s)) :\nRetire les objets s lectionn s de la liste d'exclusion de la cam ra active.\n\n" \
								+ "- delete selected (Scene object(s)) :\nRetire les objets s lectionn s dans la sc ne de la liste d'exclusion de la cam ra (s'ils s'y trouvent d j ).\n\n" \
								+ "--------------------------------------------------------\n\n" \
								+ "ACTIONS RAPIDES (Double-clics / Clic-droit)\n\n" \
								+ "- Double-clic sur une cam ra :\nLa s lectionne dans la sc ne et met   jour le panneau d'exclusion (Droite).\n\n" \
								+ "- Double-clic sur un objet exclu :\nLe s lectionne dans la sc ne.\n\n" \
								+ "- Clic droit sur le panneau exclude list :\nS lectionne tous les objets s lectionn s dans cette liste dans la sc ne."
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