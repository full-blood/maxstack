/*
================================================================================
Script Name: Aligner
Category: MaxStack
Description: Cree un Tape temporaire depuis la selection courante, parent les objets selectionnes de premier niveau au Tape head, puis permet de recaler le target sur le head en X, Y ou Z. L'option 2D garde le target au meme niveau Z pendant la creation. Les boutons H et T selectionnent rapidement le Tape head ou le target.
================================================================================
*/

macroscript MaxStack_Aligner
toolTip:"Aligner"
category:"MaxStack"
buttonText:"Aligner"
(
-- test si undefined tapeAlignArray[1]


try(destroydialog AlignerRollout)catch() 
global objs = #()
global tapeAlignArray = #()
fn getTape n = (
	append tapeAlignArray n
)

fn getCurrentTape = (
	if tapeAlignArray.count > 0 and isValidNode tapeAlignArray[1] then tapeAlignArray[1] else undefined
)
		
rollout AlignerRollout "Aligner tool" width:145 height:70 (
	button 'btn1' "Tape" pos:[10,10] width:45 height:20 align:#left toolTip:"Create a temporary Tape from the current selection"
	checkbox 'chkb1' "2D" pos:[60,10] width:35 height:20 align:#left checked:true toolTip:"Keep the target on the same Z level while creating the Tape"
	button 'btnSelHead' "H" pos:[100,10] width:18 height:20 align:#left toolTip:"Select Tape head"
	button 'btnSelTarget' "T" pos:[120,10] width:18 height:20 align:#left toolTip:"Select Tape target"
	button 'btn2' "X" pos:[10,40] width:25 height:20 align:#left toolTip:"Move the target X to the Tape head X"
	button 'btn3' "Y" pos:[40,40] width:25 height:20 align:#left toolTip:"Move the target Y to the Tape head Y"
	button 'btn4' "Z" pos:[70,40] width:25 height:20 align:#left toolTip:"Move the target Z to the Tape head Z"
	
	-- create a tape
	on btn1 pressed do (
		try(
		tapeAlignArray = #()
		
		sel = #()
		sel = getCurrentSelection()
		gr_parent = #()
	
		for i in sel do (
			if (i.parent == undefined) or ((findItem sel i.parent) == 0) then (
				append gr_parent i
			)
		)
		
		snapMode.active = true
		startObjectCreation tape returnNewNodes:true name:"ok" newNodeCallback:getTape
		if chkb1.checked  == true then (
			tapeAlignArray[1].target.pos.z = tapeAlignArray[1].pos.z
		)
		for o in gr_parent do (
			o.parent = tapeAlignArray[1]
		)
	)catch()
	)
	on btnSelHead pressed do (
		local currentTape = getCurrentTape()
		if currentTape != undefined do select currentTape
	)
	on btnSelTarget pressed do (
		local currentTape = getCurrentTape()
		if currentTape != undefined and isValidNode currentTape.target do select currentTape.target
	)
	on btn2 pressed do with undo label:"Align X" on ( ---------- align x
		local currentTape = getCurrentTape()
		if currentTape != undefined and isValidNode currentTape.target do currentTape.target.pos.x = currentTape.pos.x
-- 		updateShape()
	)
	on btn3 pressed do with undo label:"Align Y" on ( ---------- align Y
		local currentTape = getCurrentTape()
		if currentTape != undefined and isValidNode currentTape.target do currentTape.target.pos.y = currentTape.pos.y
-- 		updateShape()
	)
	on btn4 pressed do with undo label:"Align Z" on ( ---------- align Z
		local currentTape = getCurrentTape()
		if currentTape != undefined and isValidNode currentTape.target do currentTape.target.pos.z = currentTape.pos.z
-- 		updateShape()
	)
	on AlignerRollout close do (
		for o in objs do (
-- 			o.parent = undefined
		)
		try(delete tapeAlignArray[1])catch()
-- 		updateShape()
	)
)

CreateDialog AlignerRollout
)
