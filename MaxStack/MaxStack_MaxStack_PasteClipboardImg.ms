-- =====================================================
-- MaxStack_Material_PasteClipboardImg.ms
-- Colle une image du presse-papier comme texture
-- =====================================================

macroScript MaxStack_PasteClipboardImg 
    category:"MaxStack" 
    tooltip:"Paste Clipboard Image as Texture"
    buttonText:"Paste Clipboard Img"
(
    fn pasteClipboardImage =
    (
        -- Vérifier qu'il y a une sélection
        if selection.count == 0 then
        (
            messageBox "Veuillez sélectionner un objet" title:"Paste Clipboard Image"
            return false
        )
        
        try
        (
            -- Créer un bitmap temporaire depuis le presse-papier
            local clipboardBmp = bitmap 1 1
            
            -- Essayer de récupérer l'image du presse-papier
            if (pastebitmap clipboardBmp) then
            (
                -- Créer un nom de fichier temporaire
                local tempPath = (getDir #temp) + "\\clipboard_texture.png"
                
                -- Sauvegarder le bitmap
                clipboardBmp.filename = tempPath
                save clipboardBmp
                
                -- Créer un matériau avec cette texture
                local mat = StandardMaterial()
                mat.name = "Clipboard Material"
                
                local diffuseMap = Bitmaptexture fileName:tempPath
                mat.diffuseMap = diffuseMap
                mat.showInViewport = true
                
                -- Appliquer aux objets sélectionnés
                for obj in selection do
                (
                    obj.material = mat
                )
                
                format "✓ Texture du presse-papier appliquée à % objet(s)\n" selection.count
                messageBox ("Image appliquée à " + selection.count as string + " objet(s)") title:"Succès"
                
                close clipboardBmp
                return true
            )
            else
            (
                messageBox "Aucune image dans le presse-papier" title:"Erreur"
                return false
            )
        )
        catch e
        (
            messageBox ("Erreur: " + e as string) title:"Erreur"
            return false
        )
    )
    
    -- Exécuter la fonction
    pasteClipboardImage()
)
