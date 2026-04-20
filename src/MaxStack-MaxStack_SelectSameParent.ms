/*
================================================================================
Script Name: MaxStack_SelectSameParent
Category: MaxStack
Description: Sélectionne tous les objets appartenant au même parent (ou groupe) 
             que l'objet actuellement sélectionné. 
             Optimisation : Utilise les propriétés hiérarchiques natives de 
             3ds Max (parentNode.children) au lieu de boucler sur toute la scène,
             ce qui garantit une exécution instantanée même sur de gros fichiers.
================================================================================
*/

macroScript MaxStack_SelectSameParent
    category:"MaxStack" 
    tooltip:"Select all objects in the same group or parent"
    buttonText:"Sel. same Group parent"
(
    -- 1. On sécurise la sélection en prenant le premier objet sélectionné
    -- (Évite les erreurs si l'utilisateur a sélectionné plusieurs objets avec '$')
    local currentObj = selection[1]
    
    if isValidNode currentObj then
    (
        -- 2. On récupère le noeud parent de l'objet
        local parentNode = currentObj.parent
        
        -- 3. On vérifie si l'objet a bien un parent (s'il est dans un groupe)
        if isValidNode parentNode then
        (
            -- 4. On désélectionne tout (clearSelection() est plus rapide et propre que "max select none")
            clearSelection()
            
            -- 5. On sélectionne directement tous les enfants de ce parent
            -- Cela remplace ta boucle "for o in objects" de manière beaucoup plus légère
            select parentNode.children
            
            -- Optionnel : Petit retour dans le MAXScript Listener pour vérifier que tout s'est bien passé
            format ">> % objets sélectionnés appartenant au parent : %\n" parentNode.children.count parentNode.name
        )
        else
        (
            -- L'objet est à la racine, il n'a pas de parent
            messageBox "L'objet sélectionné n'a pas de parent ou n'appartient à aucun groupe." title:"Info MaxStack"
        )
    )
    else
    (
        -- Aucun objet n'était sélectionné au lancement du script
        messageBox "Veuillez sélectionner au moins un objet." title:"Erreur MaxStack"
    )
)