/*
================================================================================
Script Name: Bitmap_Downscaler
Category: MaxStack
Description: Analyse et liste toutes les textures (bitmaps) de la scène pour 
             les redimensionner afin d'optimiser la mémoire RAM et VRAM.
             - Trigger if size : Déplace automatiquement les textures dépassant 
               ce poids (en MB) dans la liste de traitement.
             - Target dimension : Résolution maximale ciblée (en pixels).
             - Refresh List : Scanne la scène et actualise la liste des bitmaps.
             - Downscale Maps : Crée une copie réduite de la texture 
               (suffixe _dsXXXX) et relinke la scène dessus.
             - Recover : Ouvre un outil secondaire permettant de retrouver et 
               de restaurer les fichiers originaux (Upscale).
             - Copy : Copie le log de la liste de traitement (chemins et 
               statuts de succès/erreur) dans le presse-papiers.
================================================================================
*/
macroScript Bitmap_Downscaler
    category:"MaxStack" 
    tooltip:"Check all bitmaps in the scene and resize with conditions"
    buttonText:"Bitmap Downscaler"
(
try(destroyDialog BitmapDownscaler) catch()
try(destroyDialog BitmapRecoverer) catch()

struct MapData (filePath, sizeMB)

-- ==========================================
-- FONCTIONS GLOBALES (Partagées par les UI)
-- ==========================================

fn compareMapSize a b =
(
    if a.sizeMB < b.sizeMB then 1
    else if a.sizeMB > b.sizeMB then -1
    else 0
)

fn formatSize sizeMB =
(
    if sizeMB < 0 do return " ERREUR  "
    local str = formattedPrint sizeMB format:"6.2f"
    return str + " MB"
)

fn collectBitmaps =
(
    local files = #()
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

-- NOUVEAU : Fonction pour déduire le chemin d'origine à partir du suffixe _dsXXXX
fn getOriginalPath fromPath =
(
    local fileExt = getFilenameType fromPath
    local baseName = getFilenameFile fromPath
    local origName = baseName
    
    local parts = filterString baseName "_"
    if parts.count > 0 do
    (
        local lastPart = parts[parts.count]
        if lastPart.count > 2 and (substring lastPart 1 2) == "ds" do
        (
            local restStr = substring lastPart 3 (lastPart.count - 2)
            if (restStr as integer) != undefined do
            (
                origName = substring baseName 1 (baseName.count - lastPart.count - 1)
            )
        )
    )
    
    if origName == baseName do return undefined

    local dirPath = getFilenamePath fromPath
    local sameExtPath = dirPath + origName + fileExt
    if doesFileExist sameExtPath do return sameExtPath

    local candidateExts = #( ".png", ".jpg", ".jpeg", ".tif", ".tiff", ".tga", ".bmp", ".exr", ".hdr", ".psd", ".webp" )
    for ext in candidateExts do
    (
        local candidatePath = dirPath + origName + ext
        if doesFileExist candidatePath do return candidatePath
    )

    local matches = getFiles (dirPath + origName + ".*")
    if matches.count > 0 do return matches[1]

    undefined
)


-- ==========================================
-- ROLLOUT 2 : RECOVERY TOOL
-- ==========================================
rollout BitmapRecoverer "Recover Original Maps" width:700 height:450
(
    label lbl_info "Textures downscalées (_ds) trouvées dans la scène :" pos:[20,20]
    dotNetControl lb_rec "System.Windows.Forms.ListBox" pos:[20,40] width:660 height:350
    button btn_do_recover "Recover Upscale (Originals)" pos:[270,400] width:180 height:30 tooltip:"Restaurer les textures d'origine"
    
    local itemsToRecover = #() -- Stocke les paires #(oldPath, newPath)
    
    fn initListBox lb = (
        lb.HorizontalScrollbar = true
        lb.SelectionMode = (dotNetClass "System.Windows.Forms.SelectionMode").MultiExtended
        lb.Font = dotNetObject "System.Drawing.Font" "Consolas" 9 (dotNetClass "System.Drawing.FontStyle").Regular
        lb.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 220 220 220
    )
    
    on BitmapRecoverer open do
    (
        initListBox lb_rec
        itemsToRecover = #()
        
        local files = collectBitmaps()
        local seen = #()
        
        for f in files where f != undefined and f != "" do
        (
            if findItem seen f == 0 do
            (
                append seen f
                local origPath = getOriginalPath f
                
                -- Si la fonction a trouvé un suffixe _dsXXXX
                if origPath != undefined do
                (
                    if doesFileExist origPath then
                    (
                        append itemsToRecover #(f, origPath)
                        lb_rec.Items.Add ("READY TO RECOVER | " + f)
                    )
                    else
                    (
                        -- Le fichier source n'existe plus
                        lb_rec.Items.Add ("ORIGINAL MISSING | " + f)
                    )
                )
            )
        )
        
        if lb_rec.Items.count == 0 do lb_rec.Items.Add "Aucune texture avec le suffixe '_ds' trouvée."
    )
    
    on btn_do_recover pressed do
    (
        if itemsToRecover.count == 0 do
        (
            messageBox "Aucune texture prête à être restaurée." title:"Info"
            return false
        )
        
        local successCount = 0
        for data in itemsToRecover do
        (
            local oldPath = data[1]
            local newPath = data[2]
            relinkMap oldPath newPath
            successCount += 1
        )
        
        messageBox ((successCount as string) + " textures ont été restaurées avec succès !") title:"Recovery Terminé"
        destroyDialog BitmapRecoverer
    )
)


-- ==========================================
-- ROLLOUT 1 : DOWNSCALER (MAIN)
-- ==========================================
rollout BitmapDownscaler "Bitmap Downscaler" width:940 height:540
(
    -- UI ELEMENTS
    label lbl1 "Trigger if Size > (MB):" pos:[20,20] width:120
    spinner sp_mb "" range:[0.1,1000.0,5.0] type:#float scale:0.1 pos:[140,18] width:60

    label lbl2 "Target Dimension (px):" pos:[220,20] width:130
    spinner sp_max "" range:[32,8192,1024] type:#integer pos:[350,18] width:80
    checkbox chk_jpg "convert to .jpg" pos:[450,20] width:110 checked:false

    -- Boutons réorganisés pour faire de la place au bouton Recover
    button btn_scan "Refresh List" pos:[570,15] width:90 height:28
    button btn_downscale "Downscale Maps" pos:[670,15] width:100 height:28
    button btn_recover "Recover" pos:[780,15] width:80 height:28 tooltip:"Ouvrir l'outil de restauration des textures"
    button btn_copy "Copy" pos:[870,15] width:50 height:28

    label lbl_all "Available Maps (Ignored):" pos:[20,60] width:200
    label lbl_sel "Maps to Downscale:" pos:[500,60] width:200

    -- .NET ListBoxes avec Scrollbars
    dotNetControl lb_all "System.Windows.Forms.ListBox" pos:[20,80] width:420 height:440
    dotNetControl lb_sel "System.Windows.Forms.ListBox" pos:[500,80] width:420 height:440

    button btn_add ">>" pos:[455,240] width:30 height:30 tooltip:"Add selected to Downscale list"
    button btn_rem "<<" pos:[455,290] width:30 height:30 tooltip:"Remove selected from Downscale list"

    -- VARIABLES
    local pythonScript = "L:\\0-Documentation\\3DS Max Configuration\\3DS Max Plugins\\Antoine\\API\\scripts\\resize_bitmap.py"
    local convertPythonScript = "L:\\0-Documentation\\3DS Max Configuration\\3DS Max Plugins\\Antoine\\API\\scripts\\convert_bitmap.py"
    local portablePythonExe = "L:\\0-Documentation\\3DS Max Configuration\\3DS Max Plugins\\Antoine\\API\\python\\python.exe"
    local pythonExe = ""
    local cachedMapList = #() 

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

    fn runPythonSilentWait path maxDim convertToJpg =
    (
        if pythonExe == "" do return false
        local qPython = "\"" + pythonExe + "\""
        local activeScript = if convertToJpg then convertPythonScript else pythonScript
        local qScript = "\"" + activeScript + "\""
        local qPath   = "\"" + path + "\""
        local sDim    = maxDim as string
        
        local cmd = "\"" + qPython + " " + qScript + " " + qPath + " " + sDim + "\""
        HiddenDOSCommand cmd prompt:"" donotwait:false
    )

    fn updateListsFromCache =
    (
        lb_all.Items.Clear()
        lb_sel.Items.Clear()
        
        for m in cachedMapList do
        (
            local str = (formatSize m.sizeMB) + " | " + m.filePath
            if m.sizeMB >= sp_mb.value then lb_sel.Items.Add str
            else lb_all.Items.Add str
        )
    )

    fn scanAndDisplay =
    (
        local files = collectBitmaps()
        local seen = #()
        cachedMapList = #()

        for f in files do
        (
            if f != undefined and f != "" do
            (
                if findItem seen f == 0 then
                (
                    append seen f
                    
                    local isAbsolute = pathConfig.isAbsolutePath f
                    local resolvedPath = pathConfig.convertPathToAbsolute f
                    local exists = doesFileExist resolvedPath
                    
                    if not isAbsolute or not exists then
                        append cachedMapList (MapData filePath:f sizeMB:-1.0)
                    else
                        append cachedMapList (MapData filePath:resolvedPath sizeMB:(getFileSizeMB resolvedPath))
                )
            )
        )

        qsort cachedMapList compareMapSize
        updateListsFromCache()
    )

    fn initListBox lb =
    (
        lb.HorizontalScrollbar = true
        lb.SelectionMode = (dotNetClass "System.Windows.Forms.SelectionMode").MultiExtended
        lb.Font = dotNetObject "System.Drawing.Font" "Consolas" 9 (dotNetClass "System.Drawing.FontStyle").Regular
        lb.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 220 220 220
    )

    on BitmapDownscaler open do
    (
        initListBox lb_all
        initListBox lb_sel
        
        if doesFileExist portablePythonExe then
            pythonExe = portablePythonExe
        else
            pythonExe = autoFindPython()
        scanAndDisplay()
    )

    on sp_mb changed val do updateListsFromCache()
    on btn_scan pressed do scanAndDisplay()
    
    -- Ouvre la nouvelle fenêtre Recover
    on btn_recover pressed do 
    (
        createDialog BitmapRecoverer
    )

    on btn_add pressed do
    (
        local selIndices = lb_all.SelectedIndices
        for i = selIndices.count - 1 to 0 by -1 do
        (
            local idx = selIndices.Item[i]
            lb_sel.Items.Add (lb_all.Items.Item[idx])
            lb_all.Items.RemoveAt idx
        )
    )

    on btn_rem pressed do
    (
        local selIndices = lb_sel.SelectedIndices
        for i = selIndices.count - 1 to 0 by -1 do
        (
            local idx = selIndices.Item[i]
            lb_all.Items.Add (lb_sel.Items.Item[idx])
            lb_sel.Items.RemoveAt idx
        )
    )

    on lb_all DoubleClick sender args do
    (
        if lb_all.SelectedIndex >= 0 do
        (
            lb_sel.Items.Add (lb_all.Items.Item[lb_all.SelectedIndex])
            lb_all.Items.RemoveAt lb_all.SelectedIndex
        )
    )

    on lb_sel DoubleClick sender args do
    (
        if lb_sel.SelectedIndex >= 0 do
        (
            lb_all.Items.Add (lb_sel.Items.Item[lb_sel.SelectedIndex])
            lb_sel.Items.RemoveAt lb_sel.SelectedIndex
        )
    )

    on btn_downscale pressed do
    (
        if pythonExe == "" do
        (
            messageBox "Impossible de trouver python.exe." title:"Erreur"
            return false
        )

        if chk_jpg.checked and not (doesFileExist convertPythonScript) do
        (
            messageBox ("Impossible de trouver convert_bitmap.py :\n" + convertPythonScript) title:"Erreur"
            return false
        )

        local count = lb_sel.Items.count
        if count == 0 do
        (
            messageBox "La liste de downscale est vide." title:"Info"
            return false
        )

        local badFilesCount = 0
        for i = 0 to count - 1 do
        (
            if matchPattern (lb_sel.Items.Item[i]) pattern:"*ERREUR*" do badFilesCount += 1
        )
        
        if badFilesCount > 0 do
        (
            local msg = "ATTENTION : " + (badFilesCount as string) + " textures sélectionnées ont des chemins invalides.\nElles seront ignorées. Voulez-vous continuer le traitement des autres ?"
            if not (queryBox msg title:"Chemins invalides") do return false
        )

        for i = 0 to count - 1 do
        (
            local itemStr = lb_sel.Items.Item[i]
            local pathStart = findString itemStr " | "
            
            if pathStart != undefined then
            (
                local sizeStr = substring itemStr 1 (pathStart - 1)
                local pathStr = substring itemStr (pathStart + 3) -1
                
                if matchPattern pathStr pattern:"* -> *" do continue
                
                if matchPattern sizeStr pattern:"*ERREUR*" then
                (
                    lb_sel.Items.set_Item i (sizeStr + " | " + pathStr + " -> (Ignoré)")
                    continue
                )

                local path = pathStr
                -- NOUVEAU SUFFIXE : Ajout de _ds devant la résolution
                local targetSuffix = "_ds" + (sp_max.value as string)
                
                local targetExt = if chk_jpg.checked then ".jpg" else (getFilenameType path)
                local pythonOutPath = (getFilenamePath path) + (getFilenameFile path) + "_small" + targetExt
                local finalPath = (getFilenamePath path) + (getFilenameFile path) + targetSuffix + targetExt

                local success = false
                local attempts = 0
                
                while attempts < 2 and not success do
                (
                    runPythonSilentWait path sp_max.value chk_jpg.checked
                    
                    local waitCount = 0
                    while (not (doesFileExist pythonOutPath)) and (waitCount < 30) do 
                    (
                        sleep 0.1
                        waitCount += 1
                    )
                    
                    if doesFileExist pythonOutPath then
                    (
                        if doesFileExist finalPath do deleteFile finalPath 
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
                    lb_sel.Items.set_Item i (sizeStr + " | " + path + " -> RELINKED (" + targetSuffix + ")")
                )
                else
                (
                    lb_sel.Items.set_Item i (sizeStr + " | " + path + " -> ERREUR (Échec script)")
                )
            )
        )

        messageBox "Processus de downscale terminé !" title:"Downscaler"
    )

    on btn_copy pressed do
    (
        if lb_sel.Items.count == 0 then
            messageBox "La liste est vide." title:"Info"
        else
        (
            local txt = "=== Textures Processed ===\r\n"
            for i = 0 to lb_sel.Items.count - 1 do txt += lb_sel.Items.Item[i] + "\r\n"
            setClipBoardText txt
            messageBox "Liste copiée dans le presse-papiers !" title:"Info"
        )
    )
)

createDialog BitmapDownscaler
)