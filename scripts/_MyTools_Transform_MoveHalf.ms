macroscript Transform_MoveHalf
toolTip:"Move Half"
category:"MyTools"
(
global position1 = (if selection.count > 0 then (position1 = selection[1].position))
global position2 = undefined

try destroyDialog middleMove catch()
rollout middleMove "" height:50 width:170 (
	button btn1 "Pos.1" align:#left width:50 pos:[25,15]
	button btn2 "Pos.2" align:#left width:50 pos:[85,15]
	
	on btn1 pressed do (
		if selection.count > 0 then (
			position1 = selection[1].position
		)else(messagebox "Please select an object first!")
	)
	on btn2 pressed do (
		if selection.count > 0 then (
			if position1 != undefined then (
				position2 = selection[1].position
				local moveVector = position2 - position1
				moveVector = moveVector/2
				for obj in selection do (
					if superclassof obj != helper then (
						obj.position -= moveVector
					)
				)
			)
		)else(messagebox "Position 1 is not set. Save Position 1 first!")
	)
)
CreateDialog middleMove
)