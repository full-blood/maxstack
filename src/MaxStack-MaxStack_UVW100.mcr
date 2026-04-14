/*
================================================================================
Script Name: MaxStack_UVW100
Category: MaxStack
Description: Applique un modificateur UVW Map (type Box) à l'objet sélectionné. 
             Ouvre une boîte de dialogue permettant à l'utilisateur de saisir 
             une valeur numérique globale. Cette valeur est ensuite appliquée 
             simultanément à la longueur, la largeur et la hauteur du Gizmo UVW.
             La fonction "Real-World Map Size" est automatiquement désactivée.
================================================================================
*/

macroScript MaxStack_UVW100
    category:"MaxStack" 
    tooltip:"Apply UVW modifier with same UVW"
    buttonText:"UVW 100"
    Icon:#("uvw100",1)
(
    -- 1. Instanciation et affichage de la boîte de dialogue .NET
    local theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" "100"
    theObj.text = "UVW general value"
    theObj.Showmodal()

    -- 2. Vérification de l'action de l'utilisateur (clic sur "OK")
    local isOkPressed = dotnet.compareenums theObj.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)
    
    if isOkPressed do
    (
        -- 3. Récupération et conversion de la valeur saisie en nombre entier
        local newStringEntered = theObj.InstanceName as integer

        -- 4. Création et configuration du modificateur UVW Map
        local m = uvwmap() 
        m.maptype = 4 -- 4 correspond au mode de projection "Box"
        m.length = newStringEntered
        m.width = newStringEntered
        m.height = newStringEntered
        m.realWorldMapSize = false
        
        -- 5. Application du modificateur sur l'objet sélectionné avec gestion d'erreur
        try (
            addModifier $ m
        ) catch (
            messageBox "Veuillez sélectionner un seul objet." title:"Erreur MaxStack"
        )
    )
)