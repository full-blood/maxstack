macroScript MaxStack_ResizeBitmaps
    category:"MaxStack" 
    tooltip:"Check all bitmaps in the scene and resize with conditions"
    buttonText:"Resize bitmaps"
(
try(destroyDialog BitmapDownscaler) catch()

struct MapData (filePath, sizeMB)

fn compareMapSize a b =
(
    if a.sizeMB < b.sizeMB then 1
    else if a.sizeMB > b.sizeMB then -1
    else 0
)

rollout BitmapDownscaler "Bitmap Downscaler - Version Dynamique" width:820 height:520
(
    -- J'ai renommé les labels pour que la logique soit 100% claire
    label lbl1 "Trigger if Size > (MB):" pos:[20,20] width:120
    spinner sp_mb "" range:[1,1000,5] type:#integer pos:[140,18] width:60

    label lbl2 "Target Dimension (px):" pos:[220,20] width:130
    spinner sp_max "" range:[32,8192,1024] type:#integer pos:[350,18] width:80

    button btn_scan "Refresh List" pos:[460,15] width:100 height:28
    button btn_downscale "Downscale Maps" pos:[570,15] width:110 height:28
    button btn_copy "Copy list" pos:[690,15] width:90 height:28

    edittext edt_output "" pos:[20,60] width:760 height:440 multiline:true readonly:true

    local pythonScript = "L:\\0-Documentation\\3DS Max Configuration\\3DS Max Plugins\\Antoine\\API\\scripts\\resize_bitmap.py"
    local pythonExe = ""

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
        -- FIX DU BUG UNDEFINED : On s'assure que le chemin est un vrai texte valide
        for m in getClassInstances bitmaptexture where (m.filename != undefined and m.filename != "") do append files m.filename
        try (for m in getClassInstances CoronaBitmap where (m.filename != undefined and m.filename != "") do append files m.filename) catch()
        try (for m in getClassInstances VRayBitmap where (m.filename != undefined and m.filename != "") do append files m.filename) catch()
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
        
        local cmd = "\"" + qPython + " " + qScript + " " + qPath + " " + sDim + "\""
        HiddenDOSCommand cmd prompt:"" donotwait:false
    )

    fn scanAndDisplay =
    (
        edt_output.text = "Scanning materials...\n"
        local files = collectBitmaps()
        local seen = #()
        local mapList = #()

        for f in files do
        (
            -- Double sécurité : on vérifie encore que f n'est pas undefined
            if f != undefined and f != "" do
            (
                if findItem seen f == 0 then
                (
                    append seen f
                    
                    local isAbsolute = pathConfig.isAbsolutePath f
                    local resolvedPath = pathConfig.convertPathToAbsolute f
                    local exists = doesFileExist resolvedPath
                    
                    if not isAbsolute or not exists then
                    (
                        append mapList (MapData filePath:f sizeMB:-1.0)
                    )
                    else
                    (
                        local sizeMB = getFileSizeMB resolvedPath
                        append mapList (MapData filePath:resolvedPath sizeMB:sizeMB)
                    )
                )
            )
        )

        qsort mapList compareMapSize

        local result = ""
        for m in mapList do
        (
            if m.sizeMB < 0 then
                result += "ERREUR CHEMIN | " + m.filePath + "\n"
            else
                result += ((floor (m.sizeMB*100+0.5)/100.0) as string) + " MB | " + m.filePath + "\n"
        )
        
        if result == "" then result = "Aucune texture trouvée dans la scène."
        edt_output.text = result
        
        return mapList
    )

    on BitmapDownscaler open do
    (
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
            messageBox "Impossible de trouver python.exe." title:"Erreur"
            return false
        )

        local mapList = scanAndDisplay()
        
        local badFiles = #()
        for m in mapList where m.sizeMB < 0 do append badFiles m.filePath
        
        if badFiles.count > 0 do
        (
            local msg = "ATTENTION : " + (badFiles.count as string) + " textures ont des chemins relatifs ou n'existent pas.\n\n"
            msg += "Exemple :\n" + badFiles[1] + "\n\n"
            msg += "Voulez-vous IGNORER ces fichiers et continuer le downscale des autres ?"
            
            if not (queryBox msg title:"Chemins invalides détectés") do
            (
                edt_output.text = "Opération annulée par l'utilisateur."
                return false
            )
        )

        edt_output.text = "Downscaling en cours, veuillez patienter...\n"
        local result = ""

        for m in mapList do
        (
            if m.sizeMB < 0 then
            (
                result += "ERREUR CHEMIN | " + m.filePath + " -> (Ignoré)\n"
            )
            else if m.sizeMB >= sp_mb.value then
            (
                local path = m.filePath
                local formattedSize = ((floor (m.sizeMB*100+0.5)/100.0) as string) + " MB"
                
                -- NOUVEAU : On prépare le vrai suffixe (_1024, _512, etc.)
                local targetDimString = sp_max.value as string
                local targetSuffix = "_" + targetDimString
                
                -- Les chemins
                local pythonOutPath = (getFilenamePath path) + (getFilenameFile path) + "_small" + (getFilenameType path)
                local finalPath = (getFilenamePath path) + (getFilenameFile path) + targetSuffix + (getFilenameType path)

                local success = false
                local attempts = 0
                
                while attempts < 2 and not success do
                (
                    runPythonSilentWait path sp_max.value
                    
                    local waitCount = 0
                    while (not (doesFileExist pythonOutPath)) and (waitCount < 30) do 
                    (
                        sleep 0.1
                        waitCount += 1
                    )
                    
                    if doesFileExist pythonOutPath then
                    (
                        -- Astuce : On renomme le _small en _1024
                        if doesFileExist finalPath do deleteFile finalPath -- Évite un crash si le _1024 existe déjà
                        renameFile pythonOutPath finalPath
                        
                        success = true
                    )
                    else
                    (
                        attempts += 1
                    )
                )

                if success then
                (
                    relinkMap path finalPath
                    result += formattedSize + " | " + path + " -> RELINKED (" + targetSuffix + ")\n"
                )
                else
                (
                    result += formattedSize + " | " + path + " -> ERREUR (Échec après 2 tentatives)\n"
                )
            )
            else
            (
                local formattedSize = ((floor (m.sizeMB*100+0.5)/100.0) as string) + " MB"
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