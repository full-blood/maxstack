-- =====================================================
-- MaxStack Update System
-- Vérifie et télécharge les mises à jour depuis GitHub
-- =====================================================

fn getRemoteText url =
(
    try
    (
        local client = dotNetObject "System.Net.WebClient"
        client.Encoding = dotNetClass "System.Text.Encoding".UTF8
        local result = client.DownloadString url
        return result
    )
    catch e
    (
        format "Erreur téléchargement texte: %\n" (e as string)
        return undefined
    )
)

fn downloadFile url dest =
(
    try
    (
        local client = dotNetObject "System.Net.WebClient"
        client.DownloadFile url dest
        return true
    )
    catch e
    (
        format "Erreur téléchargement fichier: %\n" (e as string)
        return false
    )
)

fn getLocalVersion root =
(
    local versionFile = root + "\\version.txt"
    
    if doesFileExist versionFile then
    (
        try
        (
            local f = openFile versionFile
            local version = trimRight (readLine f) "\n\r "
            close f
            return version
        )
        catch
        (
            return "0.0.0"
        )
    )
    else
    (
        return "0.0.0"
    )
)

fn compareVersions v1 v2 =
(
    -- Compare deux versions au format X.Y.Z
    -- Retourne: 1 si v1 > v2, -1 si v1 < v2, 0 si égales
    
    local parts1 = filterString v1 "."
    local parts2 = filterString v2 "."
    
    for i = 1 to 3 do
    (
        local n1 = if i <= parts1.count then (parts1[i] as integer) else 0
        local n2 = if i <= parts2.count then (parts2[i] as integer) else 0
        
        if n1 > n2 then return 1
        if n1 < n2 then return -1
    )
    
    return 0
)

fn updateMaxStack root remoteVersion =
(
    format "\n=== Mise à jour de MaxStack ===\n"
    format "Nouvelle version: %\n" remoteVersion
    
    local baseURL = "https://raw.githubusercontent.com/full-blood/maxstack/main/"
    local scriptsDir = root + "\\scripts"
    local iconsDir = root + "\\icons"
    local updateDir = root + "\\update"
    
    local updatedFiles = 0
    local failedFiles = 0
    
    try
    (
        -- Mise à jour des fichiers principaux
        local mainFiles = #("main.ms", "menu-builder.ms")
        
        for fileName in mainFiles do
        (
            local url = baseURL + fileName
            local dest = root + "\\" + fileName
            
            format "Téléchargement: %..." fileName
            if downloadFile url dest then
            (
                format " ✓\n"
                updatedFiles += 1
            )
            else
            (
                format " ✗\n"
                failedFiles += 1
            )
        )
        
        -- Mise à jour du système d'update
        format "Téléchargement: update.ms..."
        if downloadFile (baseURL + "update/update.ms") (updateDir + "\\update.ms") then
        (
            format " ✓\n"
            updatedFiles += 1
        )
        else
        (
            format " ✗\n"
            failedFiles += 1
        )
        
        -- Récupérer la liste des scripts
        format "Récupération de la liste des scripts...\n"
        local scriptList = getRemoteText (baseURL + "scripts/list.txt")
        
        if scriptList != undefined then
        (
            local scriptNames = filterString scriptList "\n"
            
            for scriptName in scriptNames do
            (
                local cleanName = trimRight scriptName "\r "
                if cleanName != "" then
                (
                    local url = baseURL + "scripts/" + cleanName
                    local dest = scriptsDir + "\\" + cleanName
                    
                    format "  Script: %..." cleanName
                    if downloadFile url dest then
                    (
                        format " ✓\n"
                        updatedFiles += 1
                    )
                    else
                    (
                        format " ✗\n"
                        failedFiles += 1
                    )
                )
            )
        )
        
        -- Récupérer la liste des icônes
        format "Récupération de la liste des icônes...\n"
        local iconList = getRemoteText (baseURL + "icons/list.txt")
        
        if iconList != undefined then
        (
            local iconNames = filterString iconList "\n"
            
            for iconName in iconNames do
            (
                local cleanName = trimRight iconName "\r "
                if cleanName != "" then
                (
                    local url = baseURL + "icons/" + cleanName
                    local dest = iconsDir + "\\" + cleanName
                    
                    format "  Icône: %..." cleanName
                    if downloadFile url dest then
                    (
                        format " ✓\n"
                        updatedFiles += 1
                    )
                    else
                    (
                        format " ✗\n"
                        failedFiles += 1
                    )
                )
            )
        )
        
        -- Mettre à jour le fichier version.txt
        local versionFile = root + "\\version.txt"
        local f = createFile versionFile
        if f != undefined then
        (
            format remoteVersion to:f
            close f
            format "\n✓ Version mise à jour: %\n" remoteVersion
        )
        
        -- Résumé
        format "\n=== Résumé de la mise à jour ===\n"
        format "Fichiers mis à jour: %\n" updatedFiles
        format "Échecs: %\n" failedFiles
        
        if failedFiles == 0 then
        (
            messageBox ("MaxStack mis à jour avec succès!\n\nVersion: " + remoteVersion + "\n\nVeuillez redémarrer 3ds Max pour appliquer les changements.") title:"Mise à jour réussie"
            return true
        )
        else
        (
            messageBox ("Mise à jour partielle.\n\n" + updatedFiles as string + " fichiers mis à jour\n" + failedFiles as string + " échecs") title:"Mise à jour partielle"
            return false
        )
    )
    catch e
    (
        format "Erreur lors de la mise à jour: %\n" (e as string)
        messageBox ("Erreur lors de la mise à jour:\n\n" + (e as string)) title:"Erreur"
        return false
    )
)

fn checkForUpdate root silent:false =
(
    format "\n=== Vérification des mises à jour ===\n"
    
    local versionLocal = getLocalVersion root
    format "Version locale: %\n" versionLocal
    
    local remoteVersionURL = "https://raw.githubusercontent.com/full-blood/maxstack/main/version.txt"
    
    format "Vérification de la version distante...\n"
    local versionRemote = getRemoteText remoteVersionURL
    
    if versionRemote != undefined then
    (
        versionRemote = trimRight versionRemote "\n\r "
        format "Version distante: %\n" versionRemote
        
        local comparison = compareVersions versionRemote versionLocal
        
        if comparison > 0 then
        (
            -- Nouvelle version disponible
            local msg = "Une nouvelle version de MaxStack est disponible!\n\n"
            msg += "Version actuelle: " + versionLocal + "\n"
            msg += "Nouvelle version: " + versionRemote + "\n\n"
            msg += "Voulez-vous mettre à jour maintenant?"
            
            local doUpdate = queryBox msg title:"Mise à jour disponible"
            
            if doUpdate then
            (
                updateMaxStack root versionRemote
            )
        )
        else if comparison == 0 then
        (
            format "✓ Vous avez la dernière version\n"
            if not silent then
                messageBox "Vous avez la dernière version de MaxStack." title:"MaxStack à jour"
        )
        else
        (
            format "⚠ Version locale plus récente que la version distante\n"
        )
    )
    else
    (
        format "✗ Impossible de vérifier les mises à jour (pas de connexion?)\n"
        if not silent then
            messageBox "Impossible de vérifier les mises à jour.\nVérifiez votre connexion internet." title:"MaxStack"
    )
)
