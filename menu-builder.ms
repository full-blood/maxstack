-- =====================================================
-- MaxStack Menu Builder
-- Génère automatiquement un menu à partir des scripts
-- =====================================================

global MaxStackMenu

fn parseScriptName filename =
(
    -- Retire l'extension .ms
    local baseName = getFilenameFile filename
    
    -- Parse le format: _Prefix_Category_ActionName
    local parts = filterString baseName "_"
    
    local result = #()
    if parts.count >= 3 then
    (
        result.prefix = parts[1]
        result.category = parts[2]
        result.action = ""
        
        -- Reconstruit le nom de l'action à partir des parties restantes
        for i = 3 to parts.count do
        (
            if i > 3 then result.action += " "
            result.action += parts[i]
        )
    )
    else
    (
        result.prefix = "MyTools"
        result.category = "Other"
        result.action = baseName
    )
    
    result.fullPath = filename
    result.baseName = baseName
    
    return result
)

fn buildMaxStackMenu =
(
    local root = (getDir #userScripts) + "\\MaxStack"
    local scriptsDir = root + "\\scripts"
    local iconsDir = root + "\\icons"
    
    -- Supprimer le menu existant s'il existe
    try (menuMan.unRegisterMenu MaxStackMenu) catch()
    
    -- Créer le menu principal
    MaxStackMenu = menuMan.createMenu "MaxStack"
    
    -- Scanner tous les scripts
    local scriptFiles = getFiles (scriptsDir + "\\*.ms")
    
    -- Organiser par catégories
    local categories = #()
    local categoryScripts = #()
    
    for scriptFile in scriptFiles do
    (
        local info = parseScriptName scriptFile
        
        -- Trouver ou créer la catégorie
        local catIndex = findItem categories info.category
        if catIndex == 0 then
        (
            append categories info.category
            append categoryScripts #()
            catIndex = categories.count
        )
        
        append categoryScripts[catIndex] info
    )
    
    -- Construire les sous-menus par catégorie
    for c = 1 to categories.count do
    (
        local catName = categories[c]
        local scripts = categoryScripts[c]
        
        -- Créer un sous-menu pour cette catégorie
        local subMenu = menuMan.createSubMenuItem catName MaxStackMenu
        local subMenuDef = menuMan.createMenu catName
        
        -- Ajouter les items du sous-menu
        for scriptInfo in scripts do
        (
            -- Créer une macroscript pour chaque script
            local macroName = "MaxStack_" + scriptInfo.baseName
            local iconPath = iconsDir + "\\" + scriptInfo.baseName + ".png"
            
            -- Vérifier si l'icône existe
            local iconExists = doesFileExist iconPath
            
            -- Générer le code de la macroscript
            local macroCode = "macroScript " + macroName + " category:\"MaxStack\" tooltip:\"" + scriptInfo.action + "\""
            
            if iconExists then
                macroCode += " icon:#(\"" + iconPath + "\", 1)"
            
            macroCode += "\n(\n"
            macroCode += "    fileIn @\"" + scriptInfo.fullPath + "\"\n"
            macroCode += ")\n"
            
            -- Exécuter la macroscript pour l'enregistrer
            try (execute macroCode) catch (format "Erreur création macro: %\n" scriptInfo.baseName)
            
            -- Créer l'item de menu
            local menuAction = menuMan.createActionItem macroName "MaxStack"
            subMenuDef.addItem menuAction -1
        )
        
        -- Lier le sous-menu à l'item
        subMenu.setSubMenu subMenuDef
        MaxStackMenu.addItem subMenu -1
    )
    
    -- Ajouter un séparateur
    local sep = menuMan.createSeparatorItem()
    MaxStackMenu.addItem sep -1
    
    -- Ajouter une option "À propos"
    macroScript MaxStack_About category:"MaxStack" tooltip:"À propos de MaxStack"
    (
        local root = (getDir #userScripts) + "\\MaxStack"
        local versionFile = root + "\\version.txt"
        local version = "inconnue"
        
        if doesFileExist versionFile then
        (
            local f = openFile versionFile
            version = readLine f
            close f
        )
        
        messageBox ("MaxStack v" + version + "\n\nGestionnaire de scripts automatisé") title:"MaxStack"
    )
    
    local aboutAction = menuMan.createActionItem "MaxStack_About" "MaxStack"
    MaxStackMenu.addItem aboutAction -1
    
    -- Enregistrer le menu dans la barre de menus principale
    local mainMenuBar = menuMan.getMainMenuBar()
    local subMenuItem = menuMan.createSubMenuItem "MaxStack" mainMenuBar
    subMenuItem.setSubMenu MaxStackMenu
    mainMenuBar.addItem subMenuItem -1
    
    -- Rafraîchir l'interface
    menuMan.updateMenuBar()
    
    format "Menu MaxStack créé avec % catégorie(s)\n" categories.count
)

-- Appeler la fonction pour construire le menu
buildMaxStackMenu()
