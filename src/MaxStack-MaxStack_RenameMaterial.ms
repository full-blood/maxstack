macroScript MaxStack_RenameMaterial
    category:"MaxStack" 
    tooltip:"Rename selected object's material"
    buttonText:"Rename material"
(
sel = selection
if sel != undefined then (
s = sel[1]
sMat = s.mat
sMatname = s.mat.name as string
	
	-- instantiate the object
	theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" sMatname
	theobj.text ="rename material of selected object"
	DialogResult = theObj.Showmodal()

	--test if the ok button was pressed
	dotnet.compareenums TheObj.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)
	--get the new text string
	NewStringEntered = theobj.InstanceName 
	NewStringEntered = NewStringEntered as string

sMat.name = NewStringEntered
	
)
)
