-- =====================================================
-- _MyTools_Transform_Mirror.ms
-- Miroir intelligent avec interface
-- =====================================================

macroScript MyTools_Mirror 
    category:"MyTools" 
    tooltip:"Smart Mirror Tool"
    buttonText:"Mirror"
(
    rollout MirrorToolRollout "Smart Mirror"
    (
        group "Axis"
        (
            radiobuttons rb_axis labels:#("X", "Y", "Z") default:1 columns:3
        )
        
        group "Options"
        (
            checkbox chk_copy "Create Copy" checked:false
            checkbox chk_instance "Instance" checked:false enabled:false
        )
        
        button btn_mirror "Mirror Selection" width:140 height:30
        
        on chk_copy changed state do
        (
            chk_instance.enabled = state
        )
        
        on btn_mirror pressed do
        (
            if selection.count == 0 then
            (
                messageBox "Veuillez sélectionner au moins un objet" title:"Mirror Tool"
                return false
            )
            
            undo "Smart Mirror" on
            (
                local axis = case rb_axis.state of
                (
                    1: [1,0,0]  -- X
                    2: [0,1,0]  -- Y
                    3: [0,0,1]  -- Z
                )
                
                local mirroredObjects = #()
                
                for obj in selection do
                (
                    local newObj = obj
                    
                    -- Créer une copie ou instance si demandé
                    if chk_copy.checked then
                    (
                        if chk_instance.checked then
                            newObj = instance obj
                        else
                            newObj = copy obj
                        
                        append mirroredObjects newObj
                    )
                    
                    -- Appliquer le miroir
                    local mirrorTM = mirrorMatrix axis [0,0,0]
                    newObj.transform = newObj.transform * mirrorTM
                    
                    -- Inverser les normales si nécessaire
                    if classOf newObj.baseObject == Editable_Poly or \
                       classOf newObj.baseObject == PolyMeshObject then
                    (
                        addModifier newObj (Normalmodifier())
                        newObj.modifiers[#Normal].flip = true
                        collapseStack newObj
                    )
                )
                
                if chk_copy.checked then
                (
                    select mirroredObjects
                    format "✓ % objet(s) miroir créé(s)\n" mirroredObjects.count
                )
                else
                (
                    format "✓ % objet(s) miroir(s) en place\n" selection.count
                )
            )
            
            messageBox "Miroir appliqué avec succès!" title:"Mirror Tool"
        )
    )
    
    createDialog MirrorToolRollout 180 180
)
