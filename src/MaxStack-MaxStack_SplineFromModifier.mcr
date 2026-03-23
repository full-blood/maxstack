macroScript MaxStack_SplineFromModifier
    category:"MaxStack" 
    tooltip:"Select the reference spline set in Array or Path Deform"
    buttonText:"Spline from modifier"
(
-- Vérifie qu'un objet est sélectionné
if selection.count == 0 then (
    messageBox "Aucun objet sélectionné."
) else (
    obj = selection[1]
    
    -- Cherche un modifier Array sur l'objet
    arrayM = undefined
	pathM = undefined
    for m in obj.modifiers do (
        if classof m == Arraymodifier then (
            arrayM = m
        )
		if classof m == Path_Deform2 or classOf m == PathDeform then (
            pathM = m
        )
    )
    
    if arrayM == undefined and pathM == undefined then (
        messageBox "L'objet sélectionné n'a pas de modifier Array ou Path Deform."
    ) else (
        -- Vérifie si une courbe de référence est assignée
        if arrayM != undefined and arrayM.type == 2 then (
            refSplineA = arrayM.referenceSpline   -- la spline de référence
			format ">> % \n" refSplineA
            if refSplineA != undefined then (
                select refSplineA
                format "Spline de référence '%'\ sélectionnée.\n" refSplineA.name
            )
		)
		if pathM != undefined and pathM.spline != undefined then (
			refSplineP = pathM.spline   -- la spline de référence
			if refSplineP != undefined then (
				select refSplineP
                format "Spline de référence '%'\ sélectionnée.\n" refSplineP.name
			)
		)
		-- gestion d'erreurs
		if refSplineA == undefined and refSplineP == undefined then
		(
			messageBox "La sélection n'utilise pas d'array avec une courbe de référence."
		)
    )
)


)