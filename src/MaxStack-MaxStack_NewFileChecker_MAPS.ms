-- ===========================================================
-- GLOBALS & CONFIG
-- ===========================================================
global bitmapList      = #()
global bitmapList_clean = #()

local W = 380
local H = 540

-- ===========================================================
-- UTILITY FUNCTIONS
-- ===========================================================

-- Collecte tous les bitmaps de la scène (Corona, VRay, Standard)
fn collectAllBitmaps =
(
    bitmapList       = #()
    bitmapList_clean = #()

    local lists = #()
    try( lists += getClassInstances BitmapTexture  )catch()
    try( lists += getClassInstances CoronaBitmap   )catch()
    try( lists += getClassInstances VRayBitmap     )catch()

    for b in lists do
    (
        local fname = ""
        try( fname = b.filename )catch()
        if fname != undefined and fname != "" then
        (
            appendIfUnique bitmapList b
            appendIfUnique bitmapList_clean fname
        )
    )
    sort bitmapList_clean
    bitmapList_clean
)

-- Vérifie si un fichier bitmap est bien sur disque et absolu
fn checkBitmapStatus b =
(
    local fname = ""
    try( fname = b.filename )catch()
    if fname == undefined or fname == "" then return "EMPTY"
    if (substring fname 2 2) != ":\\" then return "RELATIVE"
    if not (doesFileExist fname)       then return "MISSING"
    return "OK"
)

-- Relink : cherche dans le dossier du .max et ses sous-dossiers standards
fn relinkBitmaps =
(
    local subFolders = #("","Map","Maps","Texture","Textures","map","maps","texture","textures")
    local scenePath  = maxFilePath
    local fixed      = 0
    local missing    = 0

    if scenePath == "" then
    (
        messageBox "Sauvegardez d'abord votre scène (.max)." title:"Relink"
        return #(0,0)
    )

    local allBmps = #()
    try( allBmps += getClassInstances BitmapTexture )catch()
    try( allBmps += getClassInstances CoronaBitmap  )catch()
    try( allBmps += getClassInstances VRayBitmap    )catch()

    for bmp in allBmps do
    (
        local fname = ""
        try( fname = bmp.filename )catch()
        if fname == undefined or fname == "" then continue

        if not (doesFileExist fname) then
        (
            local fName   = filenameFromPath fname
            local foundIt = false

            -- cherche dans les sous-dossiers
            for sub in subFolders while not foundIt do
            (
                local testPath = scenePath + sub + "\\" + fName
                if doesFileExist testPath then
                (
                    try( bmp.filename = testPath )catch()
                    foundIt = true
                    fixed += 1
                    format "  FIXED  : % -> %\n" fName testPath
                )
            )
            if not foundIt then
            (
                missing += 1
                format "  MISSING: %\n" fName
            )
        )
    )
    atsops.refresh()
    #(fixed, missing)
)

-- ===========================================================
-- ROLLOUT PRINCIPAL
-- ===========================================================
try( DestroyDialog rlMapChecker )catch()

rollout rlMapChecker "MapStack — Map Checker" width:W height:H
(
    -- -------------------------------------------------------
    -- Widgets persistants (header + log)
    -- -------------------------------------------------------
    label  lbl_title  "MAP CHECKER"  pos:[0,14]   width:W  height:20  align:#center
    label  lbl_step   "Step 1 / 3"   pos:[0,36]   width:W  height:16  align:#center

    -- Séparateur visuel
    label  lbl_sep1   "_______________________________________________" pos:[10,52] width:360 height:12 align:#left

    -- Zone log (multiline read-only via listbox)
    listBox lst_log   ""  pos:[10,68]  width:360  height:10

    label  lbl_sep2   "_______________________________________________" pos:[10,232] width:360 height:12 align:#left

    -- -------------------------------------------------------
    -- GRAND BOUTON CENTRAL (change selon l'étape)
    -- -------------------------------------------------------
    button btn_main   "CHECK MAPS"  pos:[90,258] width:200 height:200 align:#center

    -- Petit bouton "Forcer relink" visible seulement step 2
    button btn_force  "Force relink"  pos:[110,472] width:160 height:30 enabled:false visible:false

    -- -------------------------------------------------------
    -- Variables d'état locales
    -- -------------------------------------------------------
    local currentStep   = 1
    local totalMaps     = 0
    local missingMaps   = 0
    local relativeMaps  = 0
    local emptyMaps     = 0

    -- -------------------------------------------------------
    -- Helpers UI
    -- -------------------------------------------------------
    fn setLog lines =
    (
        lst_log.items = lines
    )

    fn setStep n label =
    (
        currentStep    = n
        lbl_step.text  = ("Step " + n as string + " / 3")
        btn_main.text  = label
    )

    -- -------------------------------------------------------
    -- Variables d'état supplémentaires
    -- -------------------------------------------------------
    local wrongLocationMaps = 0
    local wrongLocationList = #()

    -- -------------------------------------------------------
    -- ÉTAPE 1 : SCAN
    -- -------------------------------------------------------
    fn doStep1_Scan =
    (
        setLog #("Scanning scene bitmaps...")
        local all = collectAllBitmaps()
        totalMaps         = bitmapList.count
        missingMaps       = 0
        relativeMaps      = 0
        emptyMaps         = 0
        wrongLocationMaps = 0
        wrongLocationList = #()

        local logLines = #()
        local scenePath = toLower maxFilePath

        for b in bitmapList do
        (
            local st = checkBitmapStatus b
            case st of
            (
                "MISSING":  ( missingMaps  += 1 )
                "RELATIVE": ( relativeMaps += 1 )
                "EMPTY":    ( emptyMaps    += 1 )
                "OK": (
                    -- La map existe sur disque : vérifier qu'elle est
                    -- dans le dossier du .max ou un de ses sous-dossiers
                    local fname = ""
                    try( fname = b.filename )catch()
                    if fname != undefined and fname != "" and scenePath != "" then
                    (
                        local fLow = toLower fname
                        if (findString fLow scenePath) == undefined then
                        (
                            wrongLocationMaps += 1
                            appendIfUnique wrongLocationList (filenameFromPath fname)
                        )
                    )
                )
            )
        )

        local okMaps = totalMaps - missingMaps - relativeMaps - emptyMaps

        append logLines ("Total bitmaps found  : " + totalMaps as string)
        append logLines ("OK, in project folder: " + (okMaps - wrongLocationMaps) as string)
        append logLines ("Missing              : " + missingMaps  as string)
        append logLines ("Relative paths       : " + relativeMaps as string)
        append logLines ("Empty paths          : " + emptyMaps    as string)

        if wrongLocationMaps > 0 then
        (
            append logLines ("Outside project      : " + wrongLocationMaps as string + "  ⚠")
            append logLines ""
            append logLines "--- Maps outside project folder ---"
            for f in wrongLocationList do
                append logLines ("  ! " + f)
        )
        else
            append logLines ("Outside project      : 0")

        append logLines ""

        if totalMaps == 0 then
        (
            append logLines "No bitmaps in scene."
            setLog logLines
            setStep 3 "NO MAPS\nFOUND"
            btn_main.enabled = false
            return false
        )

        setLog logLines

        if (missingMaps + relativeMaps) == 0 then
        (
            if wrongLocationMaps > 0 then
            (
                -- Maps trouvées mais hors projet : avertissement, pas bloquant
                setStep 3 "MAPS OK\n⚠ CHECK PATHS"
                btn_main.enabled = false
            )
            else
            (
                setStep 3 "ALL MAPS\nOK ✓"
                btn_main.enabled = false
            )
        )
        else
        (
            setStep 2 "RELINK\nMAPS"
            btn_force.enabled = true
            btn_force.visible = true
        )
    )

    -- -------------------------------------------------------
    -- ÉTAPE 2 : RELINK AUTO
    -- -------------------------------------------------------
    fn doStep2_Relink =
    (
        local logLines = #()
        append logLines "Auto-relinking..."
        setLog logLines

        local result  = relinkBitmaps()
        local fixed   = result[1]
        local missing = result[2]

        local all2    = collectAllBitmaps()
        local stillMissing = 0
        for b in bitmapList do
        (
            local st = checkBitmapStatus b
            if st == "MISSING" or st == "RELATIVE" then stillMissing += 1
        )

        append logLines ("Fixed  : " + fixed   as string)
        append logLines ("Still missing: " + missing as string)
        append logLines ""

        if stillMissing == 0 then
        (
            append logLines "All maps resolved !"
            setLog logLines
            setStep 3 "ALL MAPS\nOK ✓"
            btn_main.enabled = false
            btn_force.visible = false
        )
        else
        (
            -- Lister les fichiers encore manquants
            append logLines "--- Still missing ---"
            for b in bitmapList do
            (
                local st = checkBitmapStatus b
                if st == "MISSING" or st == "RELATIVE" then
                (
                    local fname = ""
                    try( fname = b.filename )catch()
                    append logLines ("  x " + filenameFromPath fname)
                )
            )
            setLog logLines
            setStep 3 "MAPS\nMISSING ✗"
            btn_main.enabled = false
            btn_force.visible = false
            messageBox ("Relink terminé.\n" + fixed as string + " fixé(s), " + missing as string + " toujours manquant(s).\nConsultez le log.") title:"Relink Result"
        )
    )

    -- -------------------------------------------------------
    -- EVENTS
    -- -------------------------------------------------------
    on rlMapChecker open do
    (
        setLog #("Ready.", "Press CHECK MAPS to start.")
        lbl_title.text = "MAP CHECKER"
    )

    on btn_main pressed do
    (
        case currentStep of
        (
            1: doStep1_Scan()
            2: doStep2_Relink()
        )
    )

    on btn_force pressed do
    (
        -- Ouvre l'Asset Tracker pour relink manuel
        ATSOps.visible = true
        atsops.refresh()
    )
)

CreateDialog rlMapChecker style:#(#style_titlebar, #style_sysmenu, #style_resizing)