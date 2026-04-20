/*
================================================================================
Script Name: MaxStack_SelectUnselectGroup
Category: MaxStack
Description: Ouvre récursivement tous les groupes de la sélection actuelle, 
             puis désélectionne les conteneurs de groupes (Group Heads) pour ne 
             garder sélectionnés que les objets standard de la sélection initiale.
             Optimisation : Utilisation de 'isGroupHead' pour préserver les 
             Helpers légitimes, et sélection par tableau (Array) pour de 
             meilleures performances.
================================================================================
*/

macroScript MaxStack_SelectUnselectGroup
    category:"MaxStack" 
    tooltip:"Open groups recursively and unselect group heads"
    buttonText:"Unsel. Group"
(
    -- 1. On stocke la sélection de départ dans un tableau figé
    local sel_all = selection as array
    
    if sel_all.count > 0 then
    (
        local sel_NoGroup = #()
        
        -- 2. On désactive temporairement le rafraîchissement de la vue pour accélérer le processus
        with redraw off 
        (
            -- 3. On ouvre tous les groupes de la sélection de manière récursive
            max group open recursively
            
            -- 4. On filtre le tableau de départ pour exclure les conteneurs de groupe
            for obj in sel_all do 
            (
                -- Si l'objet N'EST PAS un conteneur de groupe, on le garde
                if not (isGroupHead obj) do 
                (
                    append sel_NoGroup obj
                )
            )
            
            -- 5. On remplace directement la sélection actuelle par notre liste filtrée
            select sel_NoGroup
        )
        
        -- Optionnel : Petit retour d'information dans le Listener
        format ">> Groupes ouverts récursivement. % objet(s) conservé(s) en sélection.\n" sel_NoGroup.count
    )
    else
    (
        messageBox "Veuillez sélectionner au moins un objet ou un groupe." title:"Erreur MaxStack"
    )
)