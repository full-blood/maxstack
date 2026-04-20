/*
================================================================================
Script Name: MaxStack_OpenGroupSelectMembers
Category: MaxStack
Description: Ouvre le(s) groupe(s) sélectionné(s) et sélectionne uniquement 
             leur contenu, en excluant le conteneur du groupe (Group Head).
             Optimisation : Utilisation de 'isGroupHead' au lieu d'exclure tous 
             les 'helpers', ce qui permet de conserver la sélection d'éventuels 
             vrais objets Helper à l'intérieur du groupe.
================================================================================
*/

macroScript MaxStack_OpenGroupSelectMembers
    category:"MaxStack" 
    tooltip:"Open group and select its members"
    buttonText:"Open & Sel. items"
(
    -- 1. On stocke la sélection actuelle dans un tableau figé
    local sel = selection as array
    
    if sel.count > 0 then
    (
        local itemsToSelect = #()
        
        -- 2. On filtre les éléments (on garde tout ce qui n'est pas un conteneur de groupe)
        for obj in sel do
        (
            if not (isGroupHead obj) do
            (
                append itemsToSelect obj
            )
        )
        
        -- 3. On ouvre le(s) groupe(s) via la commande standard de 3ds Max
        max group open
        
        -- 4. On nettoie la sélection actuelle (plus rapide que "max select none")
        clearSelection()
        
        -- 5. On sélectionne directement le tableau d'éléments (évite la boucle "for o in groupItems")
        if itemsToSelect.count > 0 do
        (
            select itemsToSelect
        )
        
        -- Optionnel : Petit retour dans le MAXScript Listener
        format ">> Groupe(s) ouvert(s) : % élément(s) sélectionné(s).\n" itemsToSelect.count
    )
    else
    (
        -- Aucun objet n'était sélectionné
        messageBox "Veuillez sélectionner au moins un groupe fermé." title:"Erreur MaxStack"
    )
)