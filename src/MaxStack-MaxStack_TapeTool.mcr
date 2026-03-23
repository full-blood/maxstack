macroScript MaxStack_TapeTool
    category:"MaxStack" 
    tooltip:"Advenced Tape Tool for mesurement"
    buttonText:"Tape Tool"
(
	global TapeOption_Rollout

	-- --- 1. OUTIL DE CRÉATION ---
	tool TapeCreatorTool
	(
		local t, tgt
		local align2D = true  -- Option 2D activée par défaut
		
		on mousePoint click do
		(
			if click == 1 then 
			(
				-- Création au premier clic
				t = Tape pos:worldPoint
				tgt = TargetObject pos:worldPoint
				t.target = tgt
				
				t.name = uniqueName "Tape"
				tgt.name = t.name + ".Target"
				
				-- Application immédiate de l'alignement 2D (Z)
				if align2D then
				(
					tgt.pos.z = t.pos.z
				)
			)
			
			if click == 2 then 
			(
				select t 
				#stop 
			)
		)
		
		on mouseMove click do
		(
			if t != undefined and tgt != undefined do
			(
				tgt.pos = worldPoint
				-- Maintien de l'alignement 2D pendant le déplacement
				if align2D then
				(
					tgt.pos.z = t.pos.z
				)
			)
		)
	)

	-- --- 2. INTERFACE ---
	rollout TapeOption_Rollout "Tape Tools" width:200 height:225
	(
		local currentTape = undefined
		
		group "Info"
		(
			label lbl_len "Length: ..." align:#center
		)
		
		group "Options"
		(
			checkbox chk_2d "Mode 2D (verrouille Z)" checked:true align:#left
		)
		
		group "Sélection"
		(
			button btn_sel_tape "Sel. Tape" width:80 across:2
			button btn_sel_targ "Sel. Target" width:80
		)
		
		group "Aligner Target sur Axe"
		(
			button btn_x "X" width:50 across:3 toolTip:"Aligne sur X et sélectionne le Target"
			button btn_y "Y" width:50 toolTip:"Aligne sur Y et sélectionne le Target"
			button btn_z "Z" width:50 toolTip:"Aligne sur Z et sélectionne le Target"
		)
		
		button btn_delete "Supprimer Tape" width:180 height:20 toolTip:"Supprime le tape et ferme la fenêtre"

		timer clock_update interval:50 active:true

		fn updateDistance =
		(
			if isValidNode currentTape and isValidNode currentTape.target then
			(
				dist = distance currentTape.pos currentTape.target.pos
				lbl_len.text = "Length: " + (units.formatValue dist)
			)
			else
			(
				lbl_len.text = "Tape invalide"
				try(DestroyDialog TapeOption_Rollout)catch()
			)
		)

		fn setTape obj = 
		(
			currentTape = obj
			updateDistance()
			
			-- Sélection automatique du Target à l'ouverture
			if isValidNode currentTape.target do select currentTape.target
		)

		-- --- ACTIONS ---
		on clock_update tick do updateDistance()
		
		on btn_sel_tape pressed do 
			if isValidNode currentTape do select currentTape
			
		on btn_sel_targ pressed do 
			if isValidNode currentTape and isValidNode currentTape.target do select currentTape.target

		-- Action du bouton Supprimer
		on btn_delete pressed do
		(
			if isValidNode currentTape do 
			(
				undo "Delete Tape" on delete currentTape
			)
			try(DestroyDialog TapeOption_Rollout)catch()
		)

		on btn_x pressed do
		(
			if isValidNode currentTape and isValidNode currentTape.target do 
			(
				undo "Align Tape X" on 
				( 
					currentTape.target.pos.y = currentTape.pos.y
					currentTape.target.pos.z = currentTape.pos.z 
				)
				select currentTape.target
			)
		)
		
		on btn_y pressed do
		(
			if isValidNode currentTape and isValidNode currentTape.target do 
			(
				undo "Align Tape Y" on 
				( 
					currentTape.target.pos.x = currentTape.pos.x
					currentTape.target.pos.z = currentTape.pos.z 
				)
				select currentTape.target
			)
		)
		
		on btn_z pressed do
		(
			if isValidNode currentTape and isValidNode currentTape.target do 
			(
				undo "Align Tape Z" on 
				( 
					currentTape.target.pos.x = currentTape.pos.x
					currentTape.target.pos.y = currentTape.pos.y 
				)
				select currentTape.target
			)
		)
	)

	-- --- 3. EXÉCUTION ---
	on execute do
	(
		local foundTape = undefined
		
		-- Vérifier si un Tape ou Target est sélectionné
		if selection.count > 0 then
		(
			local sel = selection[1]
			if (classof sel == Tape) then 
				foundTape = sel
			else if (classof sel == TargetObject) then
				for o in objects where classof o == Tape do 
					if o.target == sel do foundTape = o
		)

		-- Si un Tape valide est trouvé, ouvrir l'interface
		if (isValidNode foundTape) and (isValidNode foundTape.target) then
		(
			try(DestroyDialog TapeOption_Rollout)catch()
			createDialog TapeOption_Rollout
			TapeOption_Rollout.setTape foundTape
		)
		else
		(
			-- Sinon, créer un nouveau Tape
			snapMode.active = true 
			
			startTool TapeCreatorTool 
			
			-- Après création, ouvrir l'interface si un Tape est sélectionné
			if selection.count == 1 and classof selection[1] == Tape do
			(
				local newTape = selection[1]
				try(DestroyDialog TapeOption_Rollout)catch()
				createDialog TapeOption_Rollout
				TapeOption_Rollout.setTape newTape 
			)
		)
	)
)
