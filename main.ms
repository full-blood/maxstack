-- =====================================================
-- MaxStack - Main Loader
-- Charge et initialise le système MaxStack
-- =====================================================

global MaxStackRoot = (getDir #userScripts) + "\\MaxStack"
global MaxStackScriptsDir = MaxStackRoot + "\\scripts"
global MaxStackIconsDir = MaxStackRoot + "\\icons"

-- Vérifier que MaxStack est installé
if not doesFileExist MaxStackRoot then
(
    messageBox "MaxStack n'est pas installé. Veuillez exécuter installer.ms d'abord." title:"Erreur MaxStack"
    return false
)

-- Charger le système de mise à jour
try 
(
    fileIn (MaxStackRoot + "\\update\\update.ms")
    format "Système de mise à jour chargé\n"
)
catch
(
    format "Avertissement: Impossible de charger le système de mise à jour\n"
)

-- Vérifier les mises à jour
try (checkForUpdate MaxStackRoot) catch()

-- Charger le menu builder
try 
(
    fileIn (MaxStackRoot + "\\menu-builder.ms")
    format "Menu MaxStack créé\n"
)
catch e
(
    format "Erreur lors de la création du menu: %\n" (e as string)
    
    -- Fallback: charger les scripts sans menu
    format "Chargement des scripts sans menu...\n"
    local files = getFiles (MaxStackScriptsDir + "\\*.ms")
    for f in files do
    (
        try 
        (
            fileIn f
            format "Chargé: %\n" (getFilenameFile f)
        ) 
        catch 
        (
            format "Erreur chargement: %\n" f
        )
    )
)

messageBox "MaxStack chargé avec succès!" title:"MaxStack"
true
