macroScript MaxStack_RemoveMat
    category:"MaxStack" 
    tooltip:"Remove material of all selection"
    buttonText:"Remove materials"
(
	undo on
	(
		for i in selection do
		(
			i.material = undefined
		)
	)
)
