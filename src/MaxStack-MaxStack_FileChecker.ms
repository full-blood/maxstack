macroScript MaxStack_FileChecker
    category:"MaxStack" 
    tooltip:"File checker for the library"
    buttonText:"File checker"
(
global bitmapList = #()
global bitmapList_clean = #()
offset_x = 460
offset_y = 35
margin = 10
height_btn = 30
width_btn = 90
prefix_txt = ""

--set corona render as render
renderers.current = Corona()

try(DestroyDialog fileCleaner)catch()

-- ---------------------------------------------------------
-- --- FONCTIONS POUR L'IA (Globales) ---
-- ---------------------------------------------------------

fn findMatchingImage maxFile =
(
    local dir = getFilenamePath maxFile
    local base = getFilenameFile maxFile
    local exts = #(".jpg", ".jpeg", ".png")
    for e in exts do
    (
        local img = dir + base + e
        if doesFileExist img then return img
    )
    undefined
)

fn getAiKeywords =
(
    if maxFileName == "" then
    (
        messageBox "Please save the .max file first."
        return #()
    )
    local maxPath = maxFilePath + maxFileName
    local imagePath = findMatchingImage maxPath
    if imagePath == undefined then
    (
        messageBox "No matching image found (jpg/png)."
        return #()
    )
    
    local pythonExe = "C:\\Users\\" + sysInfo.username + "\\AppData\\Local\\Microsoft\\WindowsApps\\python.exe"
    local scriptDir = "C:\\Users\\" + sysInfo.username + "\\Documents\\3ds Max 2024\\Scripts\\"
    local pythonScript = scriptDir + "_MyTools_Files_MapSearch.py"
    local keywordsFile = scriptDir + "_MyTools_Files_MapSearch__Keywords_List.txt" -- Fichier pour Fuzzy Match
    
    local tempFile = getDir #temp + "\\object_list.txt"
    
    if not (doesFileExist pythonExe) then ( messageBox "Python introuvable" return #() )
    if not (doesFileExist pythonScript) then ( messageBox "Script Python introuvable" return #() )

    if doesFileExist tempFile then deleteFile tempFile
    
    -- Construction de la commande (argument keywordsFile ajout  en 3eme pos)
    local args = "/c \"\"" + pythonExe + "\" \"" + pythonScript + "\" \"" + imagePath + "\" \"" + tempFile + "\" \"" + keywordsFile + "\"\""
    
    local p = dotNetObject "System.Diagnostics.Process"
    p.StartInfo.FileName = "cmd.exe"
    p.StartInfo.Arguments = args
    p.StartInfo.WindowStyle = (dotNetClass "System.Diagnostics.ProcessWindowStyle").Hidden
    p.StartInfo.UseShellExecute = false
    p.StartInfo.CreateNoWindow = true
    
    p.Start()
    p.WaitForExit()
    
    local keywordsFound = #()
    if doesFileExist tempFile then
    (
        local f = openFile tempFile
        while not eof f do
        (
            local line = readLine f
            if (trimLeft (trimRight line)) != "" then append keywordsFound line
        )
        close f
        return keywordsFound
    )
    else
    (
        messageBox "Erreur : Fichier r sultat non cr  ."
        return #()
    )
)

fn cleanupGlobals = (
    theObj = undefined
    bitmapList = undefined
    bitmapList_clean = undefined
    diffScaleObjs = undefined
    searchName = undefined
)

rollout fileCleaner "File Cleaner" width:560 height:560 (

	button btn_1 "show maps" width:width_btn height:height_btn pos:[offset_x,margin]
	button btn_10 "search maps" width:width_btn height:height_btn pos:[offset_x,margin+offset_y] enabled:false
	button btn_7 "force maps" width:width_btn height:height_btn pos:[offset_x,margin+2*offset_y] enabled:false


	button btn_2 "reset each pivot" width:width_btn height:height_btn pos:[offset_x,2*margin+3*offset_y]
	button btn_8 "reset grouped pivot" width:width_btn height:height_btn pos:[offset_x,2*margin+4*offset_y]

	button btn_3 "wirecolor" width:width_btn height:height_btn pos:[offset_x,3*margin+5*offset_y]
	
	button btn_4 "layers to 0" width:width_btn height:height_btn pos:[offset_x,4*margin+6*offset_y]
	
	button btn_5 "show names" width:width_btn height:height_btn pos:[offset_x,5*margin+7*offset_y]
	button btn_6 "name group" width:width_btn height:height_btn pos:[offset_x,5*margin+8*offset_y]
	button btn_9 "name selected" width:width_btn height:height_btn pos:[offset_x,5*margin+9*offset_y]
	button btn_11 "custom prefix" width:width_btn height:height_btn pos:[offset_x,5*margin+10*offset_y]
	button btn_12 "smart rename" width:width_btn height:height_btn pos:[offset_x,5*margin+11*offset_y] enabled:false
	button btn_13 "sort names" width:width_btn height:height_btn pos:[offset_x,5*margin+12*offset_y] enabled:true
	
	button btn_16 "skip ok file" width:width_btn height:height_btn pos:[offset_x-(2*width_btn)-20,6*margin+13*offset_y]
	button btn_14 "create ok file" width:width_btn height:height_btn pos:[offset_x-width_btn-10,6*margin+13*offset_y]
	button btn_15 "?" width:height_btn height:height_btn pos:[10,6*margin+13*offset_y]
	button btn_update_db "Update DB" width:60 height:height_btn pos:[50,6*margin+13*offset_y]
	
	multiListBox lst_1 "" width:440 height:38 pos:[10,10]
	
	--// function part
	
	fn searchName =
	(	
		fileCleaner.lst_1.items = #()
		if objects.count > 1000 then
		(
			if not (queryBox ("Nombre d'objets  lev  ("+(objects.count as string)+"). Continuer ?") beep:false) do return false
		)
		local allNames = for o in objects collect o.name
		fileCleaner.lst_1.items = allNames
		--fileCleaner.lst_1.refresh()
	)
	
-- 	fn searchName =
-- 	(	
-- 		fileCleaner.lst_1.items = #()
-- 		
-- 		if objects.count > 500 then
-- 		(
-- 			if queryBox ("nombre d'objets  lev  ("+(objects.count as string)+"), risque de planter, continuer ?") beep:true then
-- 			(
-- 				for o in objects do (
-- 					fileCleaner.lst_1.items = append fileCleaner.lst_1.items o.name
-- 				)
-- 			)
-- 			else
-- 			(
-- 				return false
-- 			)
-- 		)
-- 		else
-- 		(
-- 			for o in objects do (
-- 				fileCleaner.lst_1.items = append fileCleaner.lst_1.items o.name
-- 			)
-- 		)
-- 	)
	
	fn renameItemFromList itemName =
	(
		global theObj = getNodeByName itemName
		if theObj == undefined then (
			messageBox ("Object not found : " + itemName)
			return false
		)
		renameDialog = dotNetObject "MaxCustomControls.RenameInstanceDialog" (theObj.name as string)
		renameDialog.Text = "Rename object"

		dialogResult = renameDialog.Showmodal()
		
		if dotnet.compareenums dialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK) then
		(
			newName = renameDialog.InstanceName as string
			
			if newName != "" then
			(
				undo on theObj.name = newName
				
				if (fileCleaner != undefined) and (fileCleaner.lst_1 != undefined) then (
					searchName()
				)
			)
		)
	)

	fn sortNames =
	(
		-- M thode native plus robuste pour les strings
		if fileCleaner.lst_1.items.count > 1 then
		(
			fileCleaner.lst_1.items = sort fileCleaner.lst_1.items
		)
	)

	
	fn updateMap = (
		global  searchPaths = #("","Map","Maps","Texture","Textures","map","maps","texture","textures")

		fileCleaner.lst_1.items = #()
				
		try(bMaps = getClassInstances Bitmaptexture)catch(print "no texture found")
		try(cMaps = getClassInstances CoronaBitmap)catch(print "no corona texture found")
		try(vMaps = getClassInstances VRayBitmap)catch(print "no vray texture found")

		if bMaps != undefined then (for b in bMaps do (
			if ((appendIfUnique bitmapList b) == true) then (
				if b.filename != undefined and b.filename != "" and doesFileExist b.filename AND (substring b.filename 2 2) == ":\\" then (
				)else(
					appendIfUnique bitmapList b
				)
			)
		))
		if cMaps != undefined then (for c in cMaps do (
			if ((appendIfUnique bitmapList c) == true) then (
				if c.filename != undefined and c.filename != "" and doesFileExist c.filename AND (substring c.filename 2 2) == ":\\" then (
				)else(
					appendIfUnique bitmapList c
				)
			)
		))
		if vMaps != undefined then (for v in vMaps do (
			if ((appendIfUnique bitmapList v) == true) then (
				if v.filename != undefined and v.filename != "" and doesFileExist v.filename AND (substring v.filename 2 2) == ":\\" then (
				)else(
					appendIfUnique bitmapList v
				)
			)
		))
		for b in bitmapList do (
			try
			(
				local fname = undefined
				try(fname = b.filename)catch(fname = b)
				if fname != undefined and fname != "" then
				(
					if (appendIfUnique bitmapList_clean b.filename) then
					(
						fileCleaner.lst_1.items = append fileCleaner.lst_1.items b.filename
					)
				)
			)catch(format "error on filename for %\n\n" b)
		)
		fileCleaner.lst_1.items = sort fileCleaner.lst_1.items
	)

	fn searchMap = (

		--OLD SCRIPT
-- 		global  searchPaths = #("","Map","Maps","Texture","Textures","map","maps","texture","textures")

-- 		for tex in bitmapList do (
-- 			
-- 			try(local filePath = tex.filename)catch(local filePath = tex)
-- 			try(local fileName = (filenameFromPath filePath))catch(local fileName = tex)

-- 			if doesFileExist filePath then (
-- 	 			format "found directly in %\n" filePath
-- 				if ((substring filePath 2 2) != ":\\") then (
-- 					tex.filename = (maxFilePath+fileName)
-- 				)
-- 			)
-- 			else (
-- 				for m in searchPaths do (
-- 					fileToTest = (maxFilePath+m+"\\"+fileName)
-- 	 				format "search in %\n" fileToTest
-- 					if doesFileExist (fileToTest) then (
-- 						tex.filename = fileToTest
-- 						format "found in %\n" fileToTest
-- 						
-- 					)else (
-- 						print "file not found"
-- 					)
-- 				)
-- 			)
-- 		)
-- 		atsops.refresh()
-- 		updateMap()
		
		--NEW SCRIPT
		-- CONFIGURATION : Liste des noms de dossiers   scanner (tu peux en ajouter)
		local subFoldersToScan = #("","Map","Maps","Texture","Textures","map","maps","texture","textures")
		
		-- Compteurs pour le rapport final
		local countFixed = 0
		local countMissing = 0
		local totalBitmaps = 0
		
		-- R cup re le chemin du dossier actuel du fichier .max
		local currentScenePath = maxFilePath
		
		if currentScenePath == "" then (
			messageBox "Veuillez d'abord sauvegarder votre sc ne pour d finir un dossier de r f rence." title:"Erreur"
		) else (
			
			-- R cup rer toutes les textures de type Bitmap
			local allBitmaps = getClassInstances bitmapTexture
			totalBitmaps = allBitmaps.count
			
			format "--- D marrage de la recherche de bitmaps ---\n"
			
			for bmp in allBitmaps do (
				-- V rifier si un chemin de fichier est assign 
				if bmp.filename != undefined and bmp.filename != "" do (
					
					-- Si le fichier n'existe pas au chemin actuel
					if (doesFileExist bmp.filename) == false then (
						
						local fName = filenameFromPath bmp.filename
						local foundIt = false
						
						format "Manquant : %\n" fName
						
						-- 1. Chercher   la racine du dossier du projet (.max)
						local testPath = currentScenePath + fName
						if (doesFileExist testPath) then (
							bmp.filename = testPath
							foundIt = true
							format "   > Trouv    la racine : %\n" testPath
						)
						
						-- 2. Si pas trouv , chercher dans les sous-dossiers d finis
						if not foundIt do (
							for sub in subFoldersToScan do (
								testPath = currentScenePath + sub + "\\" + fName
								if (doesFileExist testPath) do (
									bmp.filename = testPath
									foundIt = true
									format "   > Trouv  dans sub/ : %\n" testPath
									exit -- Sortir de la boucle des sous-dossiers
								)
							)
						)
						
						-- Mise   jour des compteurs
						if foundIt then (
							countFixed += 1
						) else (
							countMissing += 1
							format "   X Toujours introuvable.\n"
						)
						
					) 
				)
			)
			
			-- Rafraichir l'Asset Tracker
			atsops.refresh()
			
			-- R sultat final
			local msg = "Rapport de Relink :\n\n"
			msg += "Textures retrouv es : " + (countFixed as string) + "\n"
			msg += "Toujours manquantes : " + (countMissing as string) + "\n"
			
			if countMissing > 0 do msg += "\nRegardez la fen tre Listener (F11) pour les d tails."
				
			updateMap()
		)
	)
	fn forceMaps = (
		searchMap()
		global  bitmapList = #()
		for tex in getClassInstances bitmaptexture do (
			local filePath = tex.filename		
			if (findstring filePath maxFilePath) >= 1 then (
				global newBitmapPath = (getFilenamePath filePath)
				exit
			)
		)
		for tex in getClassInstances bitmaptexture do (
			tex.filename = (newBitmapPath+(getFilenameFile tex.filename)+(getFilenameType tex.filename))
				ATSOps.visible = true
		atsops.refresh()
		)
	)
	
	-- Fonction utilitaire pour lister les layers dans la listeBox
	fn listAllLayers = (
		local layerNames = #()
		for i = 0 to (LayerManager.count - 1) do (
			append layerNames (LayerManager.getLayer i).name
		)
		fileCleaner.lst_1.items = layerNames
	)

	fn hasDiffScale obj eps:0.005 =
	(
		local s = obj.scale
		local sx = s.x
		local sy = s.y
		local sz = s.z

		(abs(sx - sy) > eps) or
		(abs(sx - sz) > eps) or
		(abs(sy - sz) > eps)
	)
	
	global diffScaleObjs = #()
	
	fn rPivot = (
		for o in objects do
		(
			if hasDiffScale o then
			(
				append diffScaleObjs o
			)
			else
			(
				CenterPivot o
				WorldAlignPivot o
				o.pivot = [o.center.x,o.center.y,o.min.z]
			)
		)
		if diffScaleObjs.count > 0 then
		(
			for o in diffScaleObjs do
			(
					ResetXForm o
					CenterPivot o
					WorldAlignPivot o
					o.pivot = [ o.center.x, o.center.y, o.min.z]
			)
		)
	)
	fn rGrpPivot = (
		max select none
		max select all
		tempGROUP = group selection
		rPivot()
	)

	fn wColor = (	
		randomcolorR = (random 0 255)
		randomcolorG = (random 0 255)
		randomcolorB = (random 0 255)
		
		local changedCount = 0

		for o in objects do (
			if o.wirecolor == (color 0 0 0) then (
				o.wirecolor = (color randomcolorR randomcolorG randomcolorB)
				changedCount += 1
			)
		)
		return changedCount
	)
	fn rlayer = (
		for o in objects do (
			if o.layer.name != "0" then (
				layer = layermanager.getLayerFromName ("0")
				layer.addNode o
			)
		)
	)

	fn getPrefix = (
		newPrefix = maxFileName
		newPrefix = substituteString newPrefix ".max" ""
		newPrefix = substituteString newPrefix "_corona" ""
		newPrefix = substituteString newPrefix "_Corona" ""
		newPrefix = substituteString newPrefix "_CORONA" ""
		newPrefix = substituteString newPrefix "_vray" ""
		newPrefix = substituteString newPrefix "_Vray" ""
		newPrefix = substituteString newPrefix "_VRAY" ""
		newPrefix = substituteString newPrefix "corona" ""
		newPrefix = substituteString newPrefix "Corona" ""
		newPrefix = substituteString newPrefix "CORONA" ""
		newPrefix = substituteString newPrefix "vray" ""
		newPrefix = substituteString newPrefix "Vray" ""
		newPrefix = substituteString newPrefix "VRAY" ""
		newPrefix = substituteString newPrefix "-corona" ""
		newPrefix = substituteString newPrefix "-Corona" ""
		newPrefix = substituteString newPrefix "-CORONA" ""
		newPrefix = substituteString newPrefix "-vray" ""
		newPrefix = substituteString newPrefix "-Vray" ""
		newPrefix = substituteString newPrefix "-VRAY" ""
		newPrefix = substituteString newPrefix "  " " "
		newPrefix = substituteString newPrefix "   " " "
		newPrefix = substituteString newPrefix "    " " "
		return newPrefix
	)

	fn allName = (
		newPrefix = getPrefix()
		undo on (
			for o in objects do (
				if (findString o.name newPrefix) == undefined then (
					if btn_11.text != "custom prefix" then (
						o.name = prefix_txt+"_"+o.name
					)else (
						o.name = newPrefix+"_"+o.name
					)
				)
			)
		)
		
	)

	fn grpName = (
		
		fileCleaner.lst_1.items = #()
		newPrefix = getPrefix()
		Selmain = #()

		for o in objects do (
			if o.parent == undefined then (
				append Selmain o
			)
		)
		undo on (
			if Selmain.count >= 2 then (
				for s in Selmain do (
					s.name = newPrefix+"_"+s.name
				)
			)else (
				for s in Selmain do (
					s.name = newPrefix
				)
			)
		)
		
	)
	
	on fileCleaner open do (
		checkerCheck = 0
		for m in sceneMaterials do (
			if (classof m) == VRayMtl then (
				checkerCheck = checkerCheck + 1
			)
			if (classof m) == PhysicalMaterial then (
				checkerCheck = checkerCheck + 1
			)
		)
		if checkerCheck != 0 then (
			messageBox "Some Vray or Physical materials found in the scene !"
		)
	)
	on btn_1 pressed do (
		if btn_1.text == "search maps" then (
			searchMap()
		)else (
			updateMap()
			btn_1.text = "search maps"
		)
	)
	--pivot
	on btn_2 pressed do (
		undo on (
			rPivot()
		)
		-- Feedback demand 
		fileCleaner.lst_1.items = #("Pivots correctly reset")
	)
	
	on btn_3 pressed do (
		local count = wColor()
		-- Feedback demand 
		if count > 0 then (
			fileCleaner.lst_1.items = #("All right, " + (count as string) + " wirecolor changed")
		) else (
			fileCleaner.lst_1.items = #("All right, no black wirecolor found")
		)
	)
	
	on btn_4 pressed do (
		if btn_4.text == "layers to 0" then (
			rLayer()
			btn_4.text = "remove\n unused layers"
			-- Feedback : Affiche tous les layers apr s avoir boug  les objets
			listAllLayers()
		)else (
			-- Supprime les layers vides
			i = LayerManager.count - 1
			while (i > 0) do
			(
				lyr = LayerManager.getLayer i
				if (lyr.name != "0" and lyr.getNumChildren() == 0) then
				(
					LayerManager.deleteLayerByName (lyr.name as string)
				)
				i = i - 1
			)
			-- Feedback : Met   jour la liste avec ce qui reste
			listAllLayers()
		)
	)
	
	on btn_5 pressed do (
		if btn_5.text == "show names" then (
			searchName()
			btn_5.text = "name all"
		)else (
			allName()
			searchName()
		)
	)
	on btn_6 pressed do (
		grpName()
		searchName()
	)
	on btn_7 pressed do (
		forceMaps()
	)
	on btn_8 pressed do (
		undo on (
			rGrpPivot()
		)
		fileCleaner.lst_1.items = #("Pivots correctly reset")
	)
	--name selected
	on btn_9 pressed do (
		newPrefix = getPrefix()
		undo on (
			for i in lst_1.selection do (
				selObj = lst_1.items[i]
				selObj = getNodeByName selObj
				selObj.name = 
				if (findString selObj.name newPrefix) == undefined then (
					if btn_11.text != "custom prefix" then (
						selObj.name = prefix_txt+"_"+selObj.name
					)else (
						selObj.name = newPrefix+"_"+selObj.name
					)
				)
			)
		)
		searchName()
	)
	--custom prefix
	on btn_11 pressed do (
		try(DestroyDialog fileCleaner_prefix)catch()
		rollout fileCleaner_prefix "Set prefix" width:220 height:80 (
			edittext txt_1 "" width:190 height:25 pos:[10,10]
			button btn_ok "ok" width:80 height:25 pos:[65,45]
			
			on fileCleaner_prefix open do (
				if prefix_txt != "" then (
					txt_1.text = prefix_txt
					
				)else (
					txt_1.text = getPrefix()
				)
			)
			on btn_ok pressed do (
				prefix_txt = txt_1.text
				btn_11.text = txt_1.text
				DestroyDialog fileCleaner_prefix
			)
		)
		CreateDialog fileCleaner_prefix
	)
	on btn_11 rightclick do (
		btn_11.text = "custom prefix"
	)
	on btn_13 pressed do
	(
		sortNames()
	)
	on btn_update_db pressed do (
		local pythonExe = "C:\\Users\\" + sysInfo.username + "\\AppData\\Local\\Microsoft\\WindowsApps\\python.exe"
		local scriptUpdate = "C:\\Users\\" + sysInfo.username + "\\Documents\\3ds Max 2024\\Scripts\\_MyTools_Update_Keywords.py"
		
		if doesFileExist scriptUpdate then (
			local cmd = "/c \"\"" + pythonExe + "\" \"" + scriptUpdate + "\" & pause\""
			ShellLaunch "cmd.exe" cmd
		) else (
			messageBox "Script update introuvable !"
		)
	)
	
	fn findOrAssignPreviewImage maxFileName =
	(
		global imgfolder = getFilenamePath maxFilePath
		global imgbaseName = getFilenameFile maxFileName
		global imgextensions = #(".jpg", ".jpeg", ".png", ".bmp")

		-- 1. check image avec m me nom
		for ext in imgextensions do
		(
			imgtestFile = imgfolder + imgbaseName + ext
			if doesFileExist imgtestFile then
			(
				format "Image trouv e : %\n" imgtestFile
			)
		)
		
		global foundImage = false
		for ext in imgextensions where not foundImage do
		(
			imgtestFile = imgfolder + imgbaseName + ext
			if doesFileExist imgtestFile then
			(
				format "Image trouv e : %\n" imgtestFile
				foundImage = true
			)
		)

		-- Si l'image existe d j , on arr te ici
		if foundImage then
		(
			messageBox ("L'image de pr visualisation existe d j ") title:"Preview image"
		)
		else
		(
			-- 2. lister toutes les images du dossier
			global imageFiles = #()
			for ext in imgextensions do
				imageFiles += getFiles (imgfolder + "*" + ext)
			
			if imageFiles.count == 0 then
			(
				messageBox "Aucune image trouv e dans ce dossier." title:"Preview image"
				-- stop ici
			)
			else
			(
				-- 3. dialog de s lection
				rollout rl_selectImage "Select preview image" width:620 height:560
				(
					listbox lb_images "" items:(for f in imageFiles collect (filenameFromPath f)) height:15 pos:[10,10] width:600
					dotNetControl pb_preview "System.Windows.Forms.PictureBox" pos:[10,260] width:600 height:240
					button bt_ok "Use selected image" width:200 align:#center offset:[0,5]
					
					on rl_selectImage open do
					(
						-- Configuration du PictureBox
						pb_preview.SizeMode = (dotNetClass "System.Windows.Forms.PictureBoxSizeMode").Zoom
						pb_preview.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
						pb_preview.BackColor = (dotNetClass "System.Drawing.Color").FromARGB 50 50 50
					)
					
					on lb_images selected idx do
					(
						-- Lib rer l'image pr c dente
						try 
						(
							if pb_preview.Image != undefined then
								pb_preview.Image.Dispose()
						) catch()
						
						-- Charger la nouvelle image
						try
						(
							pb_preview.Image = (dotNetObject "System.Drawing.Bitmap" imageFiles[idx])
						)
						catch
						(
							format "Erreur lors du chargement de l'image : %\n" imageFiles[idx]
						)
					)
					
					on bt_ok pressed do
					(
						if lb_images.selection != 0 then
						(
							sourceFile = imageFiles[lb_images.selection]
							ext = getFilenameType sourceFile
							destFile = imgfolder + imgbaseName + ext
							
							-- Lib rer l'image avant de copier
							try 
							(
								if pb_preview.Image != undefined then
									pb_preview.Image.Dispose()
							) catch()
							
							if copyFile sourceFile destFile then
							(
								format "Image copi e : % -> %\n" sourceFile destFile
								destroyDialog rl_selectImage
							)
							else
							(
								messageBox "Erreur lors de la copie du fichier." title:"Preview image"
							)
						)
						else
							messageBox "S lectionne une image." title:"Preview image"
					)
					
					on rl_selectImage close do
					(
						-- Nettoyer les ressources
						try 
						(
							if pb_preview.Image != undefined then
								pb_preview.Image.Dispose()
						) catch()
					)
				)
				
				createDialog rl_selectImage
			)
		)
	)
	on btn_14 pressed do (
		-- On pr pare les variables globales pour stocker ce qu'on trouve dans le fichier texte s'il existe
		global loaded_cat = ""
		global loaded_subcat = ""
		global loaded_keywords = #()
		
		global txt_filename = (maxFilePath+maxFileName+"_CHECKED_OK.txt")
		local fileExists = doesFileExist txt_filename
		
		if fileExists then (
			-- Lecture du fichier existant pour pr -remplir
			try (
				local f = openFile txt_filename
				while not eof f do (
					local line = readLine f
					local cleanLine = trimLeft (trimRight line)
					if cleanLine != "" then (
						if (matchPattern cleanLine pattern:"--*") then (
							-- C'est une sous-cat gorie (commence par --)
							loaded_subcat = substring cleanLine 3 -1 -- enl ve les deux tirets
						) else if (matchPattern cleanLine pattern:"-*") then (
							-- C'est une cat gorie (commence par -)
							loaded_cat = substring cleanLine 2 -1 -- enl ve le tiret
						) else (
							-- C'est un mot cl  ou le nom d'utilisateur
							-- On ignore le nom d'user si possible (souvent c'est le seul qui n'est pas un mot cl  simple)
							-- Mais dans le doute on charge tout, l'user pourra effacer
							if cleanLine != (sysInfo.username as string) then append loaded_keywords cleanLine
						)
					)
				)
				close f
			) catch()
		)

		try(DestroyDialog CHECKED_OK)catch()
			
			rollout CHECKED_OK "Categories (Smart Excel + Keywords)" width:300 height:480 (
				label 'lbcat' "Category : " pos:[10,12] width:53 height:13 align:#left
				label 'lbsubcat' "Subcategory : " pos:[10,38] width:70 height:13 align:#left
				label 'lbkeyw' "Keywords : " pos:[10,62] width:56 height:13 align:#left
				
				-- ==========================================
				-- CONTROLES DOTNET
				-- ==========================================
				dotNetControl cbx_cat "System.Windows.Forms.ComboBox" pos:[100,8] width:190 height:21
				dotNetControl cbx_subcat "System.Windows.Forms.ComboBox" pos:[100,33] width:190 height:21
				
				-- Les 15 champs keywords
				dotNetControl cbx_key1 "System.Windows.Forms.ComboBox" pos:[100,60] width:190 height:21
				dotNetControl cbx_key2 "System.Windows.Forms.ComboBox" pos:[100,85] width:190 height:21
				dotNetControl cbx_key3 "System.Windows.Forms.ComboBox" pos:[100,110] width:190 height:21
				dotNetControl cbx_key4 "System.Windows.Forms.ComboBox" pos:[100,135] width:190 height:21
				dotNetControl cbx_key5 "System.Windows.Forms.ComboBox" pos:[100,160] width:190 height:21
				dotNetControl cbx_key6 "System.Windows.Forms.ComboBox" pos:[100,185] width:190 height:21
				dotNetControl cbx_key7 "System.Windows.Forms.ComboBox" pos:[100,210] width:190 height:21
				dotNetControl cbx_key8 "System.Windows.Forms.ComboBox" pos:[100,235] width:190 height:21
				dotNetControl cbx_key9 "System.Windows.Forms.ComboBox" pos:[100,260] width:190 height:21
				dotNetControl cbx_key10 "System.Windows.Forms.ComboBox" pos:[100,285] width:190 height:21
				dotNetControl cbx_key11 "System.Windows.Forms.ComboBox" pos:[100,310] width:190 height:21
				dotNetControl cbx_key12 "System.Windows.Forms.ComboBox" pos:[100,335] width:190 height:21
				dotNetControl cbx_key13 "System.Windows.Forms.ComboBox" pos:[100,360] width:190 height:21
				dotNetControl cbx_key14 "System.Windows.Forms.ComboBox" pos:[100,385] width:190 height:21
				dotNetControl cbx_key15 "System.Windows.Forms.ComboBox" pos:[100,410] width:190 height:21
				
				button 'btn_ai' "AI Search" pos:[10,410] width:70 height:20 align:#left
				button 'btn_ok' "OK - Save" pos:[10,440] width:280 height:30 align:#left

				-- VARIABLES
				struct CategoryDataStruct ( catName, subcats = #() )
				local database = #() 
				local keyword_library = #() 
				local csvSeparator = ";"

				-- ==========================================
				-- FONCTIONS UTILITAIRES
				-- ==========================================
				
				fn initDotNetCombobox ctrl = (
					ctrl.Items.Clear()
					
					-- Auto-complete
					ctrl.AutoCompleteMode = (dotNetClass "System.Windows.Forms.AutoCompleteMode").SuggestAppend
					ctrl.AutoCompleteSource = (dotNetClass "System.Windows.Forms.AutoCompleteSource").ListItems
					ctrl.DropDownStyle = (dotNetClass "System.Windows.Forms.ComboBoxStyle").DropDown
					
					-- STYLE DARK MODE
					ctrl.BackColor = (dotNetClass "System.Drawing.Color").fromArgb 80 80 80
					ctrl.ForeColor = (dotNetClass "System.Drawing.Color").fromArgb 230 230 230
					ctrl.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
				)
				
				fn loadDatabaseFromCSV = (
					local csvPath = "C:\\Users\\" + sysInfo.username + "\\Documents\\3ds Max 2024\\Scripts\\_MyTools_Files_MapSearch_Categories_List.csv"
					if not (doesFileExist csvPath) then ( messageBox ("CSV introuvable :\n" + csvPath); return false )
					database = #()
					local f = openFile csvPath
					while not eof f do (
						local line = readLine f
						local parts = filterString line csvSeparator
						if parts.count >= 2 then (
							local cName = trimLeft (trimRight parts[1])
							local sName = trimLeft (trimRight parts[2])
							local foundCat = undefined
							for d in database do ( if d.catName == cName do ( foundCat = d; exit ) )
							if foundCat == undefined then (
								local newCat = CategoryDataStruct catName:cName
								append database newCat
								foundCat = newCat
							)
							appendIfUnique foundCat.subcats sName
						)
					)
					close f
					return true
				)

				fn loadKeywordsFromTxt = (
					local txtPath = "C:\\Users\\" + sysInfo.username + "\\Documents\\3ds Max 2024\\Scripts\\_MyTools_Files_MapSearch__Keywords_List.txt"
					keyword_library = #()
					if doesFileExist txtPath then (
						local f = openFile txtPath
						while not eof f do (
							local line = readLine f
							local cleanWord = trimLeft (trimRight line)
							if cleanWord != "" do appendIfUnique keyword_library cleanWord
						)
						close f
						sort keyword_library
					)
				)

				fn updateSubcatList selectedCatName = (
					cbx_subcat.Items.Clear()
					for d in database do (
						if d.catName == selectedCatName do (
							local sortedSubs = sort (deepcopy d.subcats)
							for s in sortedSubs do cbx_subcat.Items.Add s
							exit
						)
					)
				)

				on cbx_cat SelectedIndexChanged s e do ( updateSubcatList s.Text )

				on btn_ai pressed do (
					local aiResults = getAiKeywords()
					if aiResults.count > 0 then (
						local keywordFields = #(cbx_key1, cbx_key2, cbx_key3, cbx_key4, cbx_key5, cbx_key6, cbx_key7, cbx_key8, cbx_key9, cbx_key10, cbx_key11, cbx_key12, cbx_key13, cbx_key14, cbx_key15)
						local currentResultIndex = 1
						for field in keywordFields do (
							if field.Text == "" and currentResultIndex <= aiResults.count do (
								field.Text = aiResults[currentResultIndex]
								currentResultIndex += 1
							)
						)
						messageBox "AI Keywords filled!" title:"Success"
					)
				)
				
				on CHECKED_OK open do (
					-- 1. Initialisation
					initDotNetCombobox cbx_cat
					initDotNetCombobox cbx_subcat
					
					local keyFields = #(cbx_key1, cbx_key2, cbx_key3, cbx_key4, cbx_key5, cbx_key6, cbx_key7, cbx_key8, cbx_key9, cbx_key10, cbx_key11, cbx_key12, cbx_key13, cbx_key14, cbx_key15)
					
					for f in keyFields do initDotNetCombobox f
					
					-- 2. Chargement donn es
					loadDatabaseFromCSV()
					loadKeywordsFromTxt()
					
					local catNames = #()
					for d in database do append catNames d.catName
					sort catNames
					for c in catNames do cbx_cat.Items.Add c
					
					if keyword_library.count > 0 do (
						for k in keyword_library do (
							for f in keyFields do f.Items.Add k
						)
					)
					
					-- 3. GESTION DES DONNEES CHARGEES (Si fichier existe)
					-- Si on a des variables globales remplies, on s'en sert, sinon on auto-detecte
					if (loaded_cat != "" or loaded_subcat != "") then (
						if loaded_cat != "" do (
							cbx_cat.Text = loaded_cat
							updateSubcatList loaded_cat
						)
						if loaded_subcat != "" do cbx_subcat.Text = loaded_subcat
						
						-- Remplissage des keywords existants
						local kIndex = 1
						for k in loaded_keywords do (
							if kIndex <= 15 do (
								keyFields[kIndex].Text = k
								kIndex += 1
							)
						)
					) else (
						-- 4. AUTO-DETECTION DU CHEMIN (Seulement si fichier n'existait pas)
						searchPath = maxFilePath
						searchPathFolders = (filterString searchPath "\\")
						
						if searchPathFolders.count >= 3 do (
							local folderCat = searchPathFolders[3]
							for d in database do (
								if (d.catName == folderCat) or ((d.catName + "s") == folderCat) do (
									cbx_cat.Text = d.catName
									updateSubcatList d.catName
								)
							)
						)
						
						if searchPathFolders.count >= 4 do (
							local folderSub = searchPathFolders[4]
							local currentSubs = #()
							if cbx_cat.Text != "" then (
								for d in database do if d.catName == cbx_cat.Text do currentSubs = d.subcats
							) else (
								for d in database do join currentSubs d.subcats
							)
							for s in currentSubs do (
								if (folderSub == s) or (folderSub == (s+"s")) or (matchPattern folderSub pattern:(s+"*")) do (
									cbx_subcat.Text = s
									exit
								)
							)
						)
						
						if searchPathFolders.count >= 3 and (stricmp searchPathFolders[3] "BRANDS" == 0) do
						(
							for f in keyFields do (
								if f.Text == "" do (
									f.Text = "Brands"
									exit
								)
							)
						)
						if searchPathFolders.count >= 3 and (stricmp searchPathFolders[3] "dimensiva" == 0) do
						(
							for f in keyFields do (
								if f.Text == "" do (
									f.Text = "Dimensiva"
									exit
								)
							)
						)
					)
				)

				on btn_ok pressed do (
					--check si image du meme nom existe
					if maxFileName != "" then
					(
						findOrAssignPreviewImage maxFileName
					)
					else
					(
						messageBox "Le fichier .max n est pas sauvegard ." title:"Preview image"
					)
					
					txt_filename = (maxFilePath+maxFileName+"_CHECKED_OK.txt")
					txt_file = createfile txt_filename
					
					if cbx_cat.Text != "" then format ("-"+(cbx_cat.Text)+"\n") to:txt_file
					else format ("-.None"+"\n") to:txt_file
					
					if cbx_subcat.Text != "" then format ("--"+(cbx_subcat.Text)+"\n") to:txt_file
					
					local keyFields = #(cbx_key1, cbx_key2, cbx_key3, cbx_key4, cbx_key5, cbx_key6, cbx_key7, cbx_key8, cbx_key9, cbx_key10, cbx_key11, cbx_key12, cbx_key13, cbx_key14, cbx_key15)
					for f in keyFields do (
						if f.Text != "" do format (f.Text + "\n") to:txt_file
					)
					
					format (sysInfo.username as string) to:txt_file
					close txt_file
					print (txt_filename +" file created !")
					DestroyDialog CHECKED_OK
				)
			)
			CreateDialog CHECKED_OK
	)

	on btn_15 pressed do (
		try(DestroyDialog help_fileCleaner)catch()
		rollout help_fileCleaner "Aide : File Cleaner" width:750 height:780
		(
			label help_text "Description :" pos:[15,15] width:720 height:700 readOnly:true
			button btn_ok "OK" pos:[345,740] width:60 height:25

			on help_fileCleaner open do (
				help_text.text = "Ce script est un outil polyvalent pour le nettoyage...\n\n" \
								+ "NOUVEAU : AI Search pour les mots-cl s.\n" 
			)

			on btn_ok pressed do (
				DestroyDialog help_fileCleaner
			)
		)
		CreateDialog help_fileCleaner
	)
	on btn_16 pressed do
	(
		global txt_filename = (maxFilePath+maxFileName+"_CHECKED_OK.txt")
		if doesFileExist txt_filename == true then
		(
			messageBox "file already exist"
		)
		else
		(
			txt_filename = (maxFilePath+maxFileName+"_CHECKED_OK.txt")
			txt_file = createfile txt_filename
			format (sysInfo.username as string) to:txt_file
			close txt_file
			print (txt_filename +" file created !")
		)
	)
	on lst_1 doubleClicked itemIndex do
	(
		if itemIndex > 0 then
		(
			renameItemFromList lst_1.items[itemIndex]
		)
	)
	on fileCleaner close do
	(
		cleanupGlobals()
	)

)
CreateDialog fileCleaner
)