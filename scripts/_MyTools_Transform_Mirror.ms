macroscript Transform_Mirror
toolTip:"Mirror"
category:"MyTools"
(
	
saveCoordCenter = getCoordCenter()
saveCoordRef = getRefCoordSys()
fn getBoundingBoxCenter obj =
(
    bb = nodeLocalBoundingBox obj
)

-- Save current selection
originalSelection = selection as array

-- Pick an object
pickedObj = pickObject prompt:"Pick reference object (mirror center)"

if isValidNode pickedObj then
(
    -- Restore previous selection
    select originalSelection

    -- Get center of picked object
	centerPoint = getBoundingBoxCenter pickedObj
	centerX = (centerPoint[1].x+((centerPoint[2].x - centerPoint[1].x)/2))
	centerY = (centerPoint[1].y+((centerPoint[2].y - centerPoint[1].y)/2))
	centerZ = (centerPoint[1].z+((centerPoint[2].z - centerPoint[1].z)/2))
	centerPoint = [centerX,centerY,centerZ]

	pickedObj_center = Point pos:[centerX,centerY,centerZ]
	pickedObj_center.name = "mirror_pt_to_delete"
		
    toolMode.transformCenter() 
	if isValidNode pickedObj_center do toolMode.coordsys pickedObj_center

    max mirror
	
	
)
else
(
    print "No valid object was picked."
)

if saveCoordCenter == #selection do (
	toolMode.selectionCenter() 
)
if saveCoordCenter == #local do (
	toolMode.pivotCenter()
)
if saveCoordRef == #hybrid then (toolMode.coordsys #view)
else if saveCoordRef == #local then (toolMode.coordsys #local)
else (toolMode.coordsys #view)

try(delete $'mirror_pt_to_delete')catch("no point found")
)