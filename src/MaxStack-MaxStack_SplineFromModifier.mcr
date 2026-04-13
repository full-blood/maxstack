macroScript MaxStack_SplineFromModifier
    category:"MaxStack" 
    tooltip:"Select the reference spline set in Array, Path Deform or Sweep"
    buttonText:"Spline from modifier"
(
    if selection.count == 0 then (
        messageBox "Aucun objet sélectionné."
    ) else (
        local obj = selection[1]
        local targetRef = undefined

        -- 1. Recherche du modifier et de sa référence
        for m in obj.modifiers while targetRef == undefined do (
            if classof m == Arraymodifier then (
                if m.type == 2 and m.referenceSpline != undefined then targetRef = m.referenceSpline
            )
            else if classof m == Path_Deform2 or classof m == PathDeform or classof m == SpacewarpModifier then (
                if hasProperty m "path" then targetRef = m.path
                else if hasProperty m "spline" then targetRef = m.spline
            )
            else if classof m == Sweep then (
                if m.CustomShape == 1 and m.shapes.count > 0 and m.shapes[1] != undefined then (
                    targetRef = m.shapes[1]
                )
            )
        )
        
        -- 2. Résolution de la référence vers un Node sélectionnable
        if targetRef != undefined then (
            local finalNode = undefined
            
            if isValidNode targetRef then (
                finalNode = targetRef 
            ) else (
                -- On cherche l'objet source qui possède ce BaseObject
                local allNodes = refs.dependentNodes targetRef
                for n in allNodes where isValidNode n and n != obj do (
                    finalNode = n
                    break 
                )
            )

            -- 3. Sélection et affichage
            if finalNode != undefined then (
                -- Si l'objet est caché, on l'affiche pour pouvoir le voir/modifier
                if finalNode.isHidden then finalNode.isHidden = false
                
                select finalNode
                format "Succès : '%' sélectionnée.\n" finalNode.name
            ) else (
                messageBox "Référence trouvée, mais l'objet source n'existe plus ou est introuvable."
            )
        ) else (
            messageBox "Aucune spline de référence (Array, Path, Sweep Custom) détectée sur cet objet."
        )
    )
)