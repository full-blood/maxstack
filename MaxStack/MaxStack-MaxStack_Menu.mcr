macroScript MaxStack_Menu
category:"MaxStack"
buttonText:"MaxStack"
(
    on populateDynamicMenu menuRoot do
    (
        MaxStackTableId = undefined
        
        for i = 1 to actionMan.numActionTables do
        (
            actionTableItem = actionMan.getActionTable i
            
            if actionTableItem.name == "MaxStack" then
                MaxStackTableId = actionTableItem.id
        )
        
        if MaxStackTableId != undefined then
        (
            menuRoot.AddAction MaxStackTableId "MaxStack_Mirror`MaxStack" title:"Mirror"
        )
    )
)