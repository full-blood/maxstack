/*
================================================================================
Script Name: MaxStack_ScriptHelper
Category: MaxStack
Description: Gestionnaire de scripts MaxStack. 
Affiche une description si disponible pour chaque script.
================================================================================
*/

macroScript MaxStack_ScriptManager
    category:"MaxStack" 
    tooltip:"MaxStack Scripts description"
    buttonText:"MaxStack Help"
(
    rollout MaxStack_Manager_UI "MaxStack Script Manager" width:450 height:320
    (
        -- Stockage : #( #(NomBouton, Description), ... )
        local scriptsData = #()
        
        dropdownlist ddl_scripts "Scripts MaxStack disponibles :"
        label lbl_desc "" height:200 align:#left
        
        fn loadScripts = (
            scriptsData = #() 
            local macroFiles = getFiles (getDir #userMacros + "\\*MaxStack*.mcr")
            
            for file in macroFiles do (
                local f = openFile file
                local headerStr = ""
                local bText = (filenameFromPath file) -- Nom par défaut si buttonText non trouvé
                local isDescription = false
                
                if f != undefined do (
                    while not eof f do (
                        local l = readLine f
                        local cleanLine = trimLeft (trimRight l)
                        
                        -- 1. Recherche du buttonText (ce qui sera affiché dans la liste)
                        if matchPattern cleanLine pattern:"*buttonText:*" then (
                            local tokens = filterString l "\"" -- On découpe par les guillemets
                            if tokens.count >= 2 do bText = tokens[2]
                        )
                        
                        -- 2. Recherche du début de la description
                        if matchPattern cleanLine pattern:"Description:*" ignoreCase:true then (
                            isDescription = true
                            local textAfter = substring cleanLine 13 -1
                            headerStr += (trimLeft textAfter) + "\r\n"
                        )
                        -- 3. Capture des lignes suivantes de la description
                        else if isDescription and cleanLine != "*/" and not matchPattern cleanLine pattern:"*====*" then (
                            -- Si on tombe sur macroScript, on a fini la description
                            if matchPattern cleanLine pattern:"*macroScript*" then (
                                isDescription = false
                            ) else (
                                headerStr += cleanLine + "\r\n"
                            )
                        )
                    )
                    close f
                )
                
                -- Vérification si une description a été trouvée
                if trimLeft (trimRight headerStr) == "" do (
                    headerStr = "pas encore de description"
                )
                
                append scriptsData #(bText, headerStr)
            )
            
            -- Tri alphabétique de la liste par le nom du bouton
            fn compareNames v1 v2 = (
                if v1[1] < v2[1] then -1 else if v1[1] > v2[1] then 1 else 0
            )
            qsort scriptsData compareNames
            
            -- Mise à jour de la liste déroulante
            local nameList = for s in scriptsData collect s[1]
            ddl_scripts.items = nameList
        )
        
        -- Initialisation au lancement
        on MaxStack_Manager_UI open do (
            loadScripts()
            if scriptsData.count > 0 do (
                lbl_desc.text = scriptsData[1][2]
            )
        )
        
        -- Changement de script dans la liste
        on ddl_scripts selected idx do (
            lbl_desc.text = scriptsData[idx][2]
        )
    )
    
    createdialog MaxStack_Manager_UI
)