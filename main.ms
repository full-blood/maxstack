local root = (getDir #userScripts) + "/MaxStack"
local scriptsDir = root + "/scripts"

-- Charger le système d'update
fileIn (root + "/update/update.ms")

-- Lancer l'update
checkForUpdate root

-- Charger tous les scripts du dossier scripts
local files = getFiles (scriptsDir + "/*.ms")

for f in files do
(
    try (fileIn f) catch (format "Erreur chargement script: %\n" f)
)

messageBox "MaxStack chargé."
