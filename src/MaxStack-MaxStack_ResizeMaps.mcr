macroScript MaxStack_ResizeMaps
    category:"MaxStack" 
    tooltip:"Check all bitmaps in the scene and resize with conditions"
    buttonText:"Resize bitmaps"
(
try(destroyDialog BitmapDownscaler) catch()

-- Structure pour lier le chemin du fichier et sa taille
struct MapData (filePath, sizeMB)

-- Fonction de tri personnalisée (du plus lourd au plus léger)
fn compareMapSize a b =
(
    if a.sizeMB < b.sizeMB then 1
    else if a.sizeMB > b.sizeMB then -1
    else 0
)

rollout BitmapDownscaler "Bitmap Downscaler - Etape 2 : Downscale" width:820 height:520
(
    label lbl1 "Min file size (MB):" pos:[20,20] width:120
    spinner sp_mb "" range:[1,1000,5] type:#integer pos:[140,18] width:60

    label lbl2 "Max dimension (px):" pos:[220,20] width:140
    spinner sp_max "" range:[32,8192,1024] type:#integer pos:[360,18] width:80

    button btn_scan "Refresh List" pos:[460,15] width:100 height:28
    button btn_downscale "Downscale Maps" pos:[570,15] width:110 height:28
    button btn_copy "Copy list" pos:[690,15] width:90 height:28

    edittext edt_output "" pos:[20,60] width:760 height:440 multiline:true readonly:true

    -- Variables globales au rollout
    local pythonScript = "L:\\0-Documentation\\3DS Max Configuration\\3DS Max Plugins\\Antoine\\API\\scripts\\resize_bitmap.py"
    local pythonExe = ""

    -- Fonctions de base
    fn autoFindPython =
    (
        local localAppData = systemTools.getEnvVariable "LOCALAPPDATA"
        local searchDirs = #(
            localAppData + "\\Programs\\Python\\*", 
            "C:\\Program Files\\Python*\\",
            "C:\\Python*\\"
        )
        local foundExe = ""
        for searchDir in searchDirs do
        (
            local folders = getDirectories searchDir
            for folder in folders do
            (
                local exe = folder + "python.exe"
                if doesFileExist exe do foundExe = exe 
            )
        )
        return foundExe
    )

    fn getFileSizeMB path =
    (
        if doesFileExist path then (getFileSize path as float) / 1024 / 1024 else -1.0
    )

    fn collectBitmaps =
    (
        local files = #()
        for m in getClassInstances bitmaptexture where m.filename != "" do append files m.filename
        try (for m in getClassInstances CoronaBitmap where m.filename != "" do append files m.filename) catch()
        try (for m in getClassInstances VRayBitmap where m.filename != "" do append files m.filename) catch()
        files
    )

    fn relinkMap oldPath newPath =
    (
        for m in getClassInstances bitmaptexture where m.filename == oldPath do m.filename = newPath
        try (for m in getClassInstances CoronaBitmap where m.filename == oldPath do m.filename = newPath) catch()
        try (for m in getClassInstances VRayBitmap where m.filename == oldPath do m.filename = newPath) catch()
    )

    fn runPythonSilentWait path maxDim =
    (
        if pythonExe == "" do return false
        
        local qPython = "\"" + pythonExe + "\""
        local qScript = "\"" + pythonScript + "\""
        local qPath   = "\"" + path + "\""
        local sDim    = maxDim as string
        
        -- La commande silencieuse et protégée pour Windows
        local cmd = "\"" + qPython + " " + qScript + " " + qPath + " " + sDim + "\""
        
        HiddenDOSCommand cmd prompt:"" donotwait:false
    )

    -- La fonction qui scanne et retourne la liste triée
    fn scanAndDisplay =
    (
        edt_output.text = "Scanning materials...\n"
        local files = collectBitmaps()
        local seen = #()
        local mapList = #()

        for f in files do
        (
            local path = pathConfig.convertPathToAbsolute f
            if findItem seen path == 0 then
            (
                append seen path
                local sizeMB = getFileSizeMB path
                append mapList (MapData filePath:path sizeMB:sizeMB)
            )
        )

        qsort mapList compareMapSize

        local result = ""
        for m in mapList do
        (
            local formattedSize = if m.sizeMB >= 0 then (((floor (m.sizeMB*100+0.5)/100.0) as string) + " MB") else "Introuvable"
            result += formattedSize + " | " + m.filePath + "\n"
        )
        
        if result == "" then result = "Aucune texture trouvée dans la scène."
        edt_output.text = result
        
        -- On retourne la liste pour pouvoir s'en servir dans le bouton Downscale
        return mapList
    )

    -- Événements
    on BitmapDownscaler open do
    (
        -- On cherche Python une seule fois à l'ouverture
        pythonExe = autoFindPython()
        scanAndDisplay()
    )

    on btn_scan pressed do
    (
        scanAndDisplay()
    )

    on btn_downscale pressed do
    (
        if pythonExe == "" do
        (
            messageBox "Impossible de trouver python.exe automatiquement." title:"Erreur"
            return false
        )

        edt_output.text = "Downscaling en cours, veuillez patienter...\n"
        
        -- On relance un scan frais pour être sûr d'avoir les bonnes infos
        local mapList = scanAndDisplay() 
        local result = ""

        for m in mapList do
        (
            local formattedSize = ((floor (m.sizeMB*100+0.5)/100.0) as string) + " MB"
            
            -- Si le fichier est plus lourd que la limite choisie par l'utilisateur
            if m.sizeMB >= sp_mb.value then
            (
                local path = m.filePath
                local smallPath = (getFilenamePath path) + (getFilenameFile path) + "_small" + (getFilenameType path)

                -- 1. On lance Python et on attend la fermeture de la console
                runPythonSilentWait path sp_max.value

                -- NOUVEAU : On donne à Windows jusqu'à 2 secondes (20 x 0.1s) pour finaliser l'écriture du fichier
                local waitCount = 0
                while (not (doesFileExist smallPath)) and (waitCount < 20) do
                (
                    sleep 0.1
                    waitCount += 1
                )

                -- 2. On vérifie si le fichier est enfin là
                if doesFileExist smallPath then
                (
                    relinkMap path smallPath
                    result += formattedSize + " | " + path + " -> RELINKED (_small)\n"
                )
                else
                (
                    result += formattedSize + " | " + path + " -> ERREUR PYTHON (ou trop long à sauver)\n"
                )
            )
            else
            (
                -- Le fichier est en dessous de la limite, on le laisse tranquille
                result += formattedSize + " | " + m.filePath + " -> (OK, ignoré)\n"
            )
        )

        edt_output.text = result
        messageBox "Processus terminé !" title:"Downscaler"
    )

    on btn_copy pressed do
    (
        setClipBoardText edt_output.text
    )
)

createDialog BitmapDownscaler
)