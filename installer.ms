-- =====================================================
-- MaxStack Installer
-- Installe ou met à jour MaxStack
-- =====================================================

fn deleteAllFilesRecursively folderPath =
(
    try 
    (
        -- Supprime tous les fichiers du dossier
        local files = getFiles (folderPath + "\\*.*")
        for f in files do deleteFile f

        -- Parcours récursif des sous-dossiers
        local subFolders = getDirectories (folderPath + "\\*")
        for sub in subFolders do
        (
            deleteAllFilesRecursively sub
            -- Essayer de supprimer le dossier vide
            try (DOSCommand ("rmdir \"" + sub + "\"")) catch()
        )
    ) 
    catch e 
    (
        format "Erreur lors de la suppression dans % : %\n" folderPath (e as string)
    )
)

fn installMaxStack =
(
    local installerDir = getFilenamePath (getSourceFileName())
    local targetRoot = (getDir #userScripts) + "\\MaxStack"
    
    format "\n=== Installation de MaxStack ===\n"
    format "Source: %\n" installerDir
    format "Destination: %\n" targetRoot
    
    try 
    (
        -- Suppression de l'ancienne installation si elle existe
        if doesFileExist targetRoot then
        (
            format "Suppression de l'ancienne version...\n"
            deleteAllFilesRecursively targetRoot
            sleep 0.5
        )
        
        -- Création de la structure de dossiers
        format "Création de la structure...\n"
        if not doesFileExist targetRoot do makeDir targetRoot
        if not doesFileExist (targetRoot + "\\icons") do makeDir (targetRoot + "\\icons")
        if not doesFileExist (targetRoot + "\\update") do makeDir (targetRoot + "\\update")
        if not doesFileExist (targetRoot + "\\scripts") do makeDir (targetRoot + "\\scripts")
        
        -- Copie des fichiers principaux
        format "Copie des fichiers principaux...\n"
        local mainFiles = #("main.ms", "version.txt", "menu-builder.ms")
        local copiedMain = 0
        
        for fileName in mainFiles do
        (
            local srcFile = installerDir + fileName
            local dstFile = targetRoot + "\\" + fileName
            
            if doesFileExist srcFile then
            (
                if copyFile srcFile dstFile then
                (
                    format "  ✓ %\n" fileName
                    copiedMain += 1
                )
                else
                    format "  ✗ Échec: %\n" fileName
            )
        )
        
        -- Copie du système de mise à jour
        format "Copie du système de mise à jour...\n"
        local updateSrc = installerDir + "update\\update.ms"
        local updateDst = targetRoot + "\\update\\update.ms"
        if doesFileExist updateSrc then
        (
            if copyFile updateSrc updateDst then
                format "  ✓ update.ms\n"
            else
                format "  ✗ Échec: update.ms\n"
        )
        
        -- Copie des scripts
        format "Copie des scripts...\n"
        local scripts = getFiles (installerDir + "scripts\\*.ms")
        local copiedScripts = 0
        
        for s in scripts do
        (
            local fileName = getFilenameFile s + ".ms"
            local dstFile = targetRoot + "\\scripts\\" + fileName
            
            if copyFile s dstFile then
            (
                format "  ✓ %\n" fileName
                copiedScripts += 1
            )
            else
                format "  ✗ Échec: %\n" fileName
        )
        
        -- Copie des icônes
        format "Copie des icônes...\n"
        local icons = getFiles (installerDir + "icons\\*.png")
        local copiedIcons = 0
        
        for ic in icons do
        (
            local fileName = getFilenameFile ic + ".png"
            local dstFile = targetRoot + "\\icons\\" + fileName
            
            if copyFile ic dstFile then
            (
                format "  ✓ %\n" fileName
                copiedIcons += 1
            )
            else
                format "  ✗ Échec: %\n" fileName
        )
        
        -- Résumé de l'installation
        format "\n=== Résumé de l'installation ===\n"
        format "Fichiers principaux: %\n" copiedMain
        format "Scripts: %\n" copiedScripts
        format "Icônes: %\n" copiedIcons
        
        -- Créer un script de démarrage automatique
        local startupFile = (getDir #userStartupScripts) + "\\MaxStack_Startup.ms"
        local f = createFile startupFile
        if f != undefined then
        (
            format "-- MaxStack Auto-Loader\n" to:f
            format "fileIn @\"%\\main.ms\"\n" targetRoot to:f
            close f
            format "\n✓ Script de démarrage créé: %\n" startupFile
        )
        
        -- Message final
        local msg = "MaxStack installé avec succès!\n\n"
        msg += copiedScripts as string + " scripts\n"
        msg += copiedIcons as string + " icônes\n\n"
        msg += "Le menu MaxStack sera disponible au prochain démarrage de 3ds Max.\n\n"
        msg += "Voulez-vous charger MaxStack maintenant?"
        
        local loadNow = queryBox msg title:"Installation réussie"
        
        if loadNow then
        (
            fileIn (targetRoot + "\\main.ms")
        )
        
        return true
    )
    catch e
    (
        messageBox ("Erreur lors de l'installation:\n\n" + (e as string)) title:"Erreur MaxStack"
        return false
    )
)

-- Lancer l'installation
installMaxStack()
