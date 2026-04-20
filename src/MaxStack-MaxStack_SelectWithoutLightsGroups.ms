/*
================================================================================
Script Name: MaxStack_SelectWithoutLightsGroups
Category: MaxStack
Description: Filtre la sélection actuelle pour en exclure les lumières, les 
             proxys (CProxy), les objets cibles (Targetobject) et les 
             conteneurs de groupes. Les groupes préalablement sélectionnés 
             sont ouverts avant d'appliquer le filtre.
             Optimisation : Utilisation de "isGroupHead" plutôt que d'exclure 
             tous les objets de classe "helper". Sélection finale par tableau 
             pour des performances instantanées.
================================================================================
*/

macroScript MaxStack_SelectWithoutLightsGroups
    category:"MaxStack" 
    tooltip:"Select without Lights & Groups"
    buttonText:"Sel. without lights/groups"
(
    -- 1. On stocke la sélection de départ dans un tableau figé
    local sel = selection as array
    
    if sel.count > 0 then
    (
        local itemsToKeep = #()
        
        -- 2. On ouvre les groupes actuellement sélectionnés (comme dans ton script original)
        max group open
        
        -- 3. On filtre les éléments du tableau de départ
        for obj in sel do 
        (
            -- On isole les conditions pour que le code soit plus lisible
            local isLight = (superClassOf obj == light)
            local isCProxy = (classOf obj == CProxy)
            local isTarget = (classOf obj == Targetobject)
            local isGroup = (isGroupHead obj)
            
            -- Si l'objet ne correspond à AUCUNE de ces catégories, on le garde
            if not (isLight or isCProxy or isTarget or isGroup) do
            (
                append itemsToKeep obj
            )
        )
        
        -- 4. On vide la sélection de la scène
        clearSelection()
        
        -- 5. On sélectionne tous les objets validés d'un seul coup
        if itemsToKeep.count > 0 do
        (
            select itemsToKeep
        )
        
        -- Optionnel : Petit retour d'information dans le Listener
        format ">> Sélection filtrée : % objet(s) conservé(s).\n" itemsToKeep.count
    )
    else
    (
        messageBox "Veuillez d'abord sélectionner des objets." title:"Info MaxStack"
    )
)