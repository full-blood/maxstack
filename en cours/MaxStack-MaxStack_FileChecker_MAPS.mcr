    -- ===========================================================
    -- GLOBALS & CONFIG
    -- ===========================================================
    global bitmapList       = #()
    global bitmapList_clean = #()

    try(DestroyDialog rlMapChecker) catch()

    -- ===========================================================
    -- UTILITY FUNCTIONS
    -- ===========================================================

    fn collectAllBitmaps =
    (
        bitmapList       = #()
        bitmapList_clean = #()

        local lists = #()
        try( join lists (getClassInstances BitmapTexture) )catch()
        try( join lists (getClassInstances CoronaBitmap)  )catch()
        try( join lists (getClassInstances VRayBitmap)    )catch()

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
        return bitmapList_clean
    )

    fn checkBitmapStatus b =
    (
        local fname = ""
        try( fname = b.filename )catch()
        
        if fname == undefined or fname == "" then return "EMPTY"
        if not (pathConfig.isAbsolutePath fname) then return "RELATIVE"
        if not (doesFileExist fname) then return "MISSING"
        
        return "OK"
    )

    -- Relink : cherche dans le dossier du .max et ses sous-dossiers
    -- Paramètre 'doFixOutside' (booléen) pour activer la recherche locale des maps externes
    fn relinkBitmaps doFixOutside =
    (
        local subFolders = #("","Map","Maps","Texture","Textures","map","maps","texture","textures")
        local scenePath  = maxFilePath
        local fixedCount = 0
        local missingCount = 0

        if scenePath == "" then
        (
            messageBox "Veuillez d'abord sauvegarder votre scène (.max)." title:"MaxStack - Relink"
            return #(0,0)
        )

        local allBmps = #()
        try( join allBmps (getClassInstances BitmapTexture) )catch()
        try( join allBmps (getClassInstances CoronaBitmap)  )catch()
        try( join allBmps (getClassInstances VRayBitmap)    )catch()

        for bmp in allBmps do
        (
            local fname = ""
            try( fname = bmp.filename )catch()
            if fname == undefined or fname == "" then continue

            local isAbs = pathConfig.isAbsolutePath fname
            local isExisting = doesFileExist fname
            local isOutside = false
            
            -- Détection si la map est hors du projet
            if isAbs and isExisting and scenePath != "" do
            (
                if (findString (toLower fname) (toLower scenePath)) == undefined do isOutside = true
            )

            -- On traite si : relatif, manquant, OU (map externe ET option cochée)
            if not isAbs or not isExisting or (doFixOutside and isOutside) then
            (
                local fNameOnly = filenameFromPath fname
                local foundIt = false

                -- Cherche dans le dossier scène et ses sous-dossiers
                for sub in subFolders while not foundIt do
                (
                    local testPath = scenePath
                    if sub != "" do testPath += sub + "\\"
                    testPath += fNameOnly
                    
                    if doesFileExist testPath then
                    (
                        -- Sécurité : on s'assure qu'on ne relink pas vers le même chemin exact
                        if (toLower fname) != (toLower testPath) do
                        (
                            try( bmp.filename = testPath )catch()
                            foundIt = true
                            fixedCount += 1
                            format "  FIXED  : % -> %\n" fNameOnly testPath
                        )
                    )
                )
                
                -- On compte comme manquante uniquement si elle n'a pas été trouvée ET qu'elle était vraiment en erreur
                if not foundIt and (not isAbs or not isExisting) then
                (
                    missingCount += 1
                    format "  MISSING: %\n" fNameOnly
                )
            )
        )
        atsops.refresh()
        return #(fixedCount, missingCount)
    )

    -- ===========================================================
    -- ROLLOUT PRINCIPAL
    -- ===========================================================
    rollout rlMapChecker "MaxStack — Map Checker" width:380 height:540
    (
        label  lbl_title  "MAP CHECKER"  pos:[0,14]   width:380  height:20  align:#center
        label  lbl_step   "Step 1 / 3"   pos:[0,36]   width:380  height:16  align:#center
        label  lbl_sep1   "_______________________________________________" pos:[10,52] width:360 height:12 align:#left
        
        listBox lst_log   ""  pos:[10,68]  width:360  height:10
        label  lbl_sep2   "_______________________________________________" pos:[10,232] width:360 height:12 align:#left

        -- Nouvelle case à cocher pour la recherche locale des maps externes
        checkbox chk_fixOutside "Relink 'Outside' maps to local folder if found" pos:[75,245] checked:true visible:false

        -- Boutons ajustés
        button btn_main   "CHECK MAPS"  pos:[90,265] width:200 height:190 align:#center
        button btn_force  "Force relink"  pos:[110,472] width:160 height:30 enabled:false visible:false

        local currentStep   = 1
        local totalMaps     = 0
        local missingMaps   = 0
        local relativeMaps  = 0
        local emptyMaps     = 0
        local wrongLocationMaps = 0
        local wrongLocationList = #()

        fn setLog lines = ( lst_log.items = lines )
        fn setStep n stepLabel =
        (
            currentStep    = n
            lbl_step.text  = ("Step " + n as string + " / 3")
            btn_main.text  = stepLabel
        )

        -- ÉTAPE 1 : SCAN
        fn doStep1_Scan =
        (
            setLog #("Scanning scene bitmaps...")
            collectAllBitmaps()
            
            totalMaps         = bitmapList.count
            missingMaps       = 0
            relativeMaps      = 0
            emptyMaps         = 0
            wrongLocationMaps = 0
            wrongLocationList = #()
            chk_fixOutside.visible = false

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
                for f in wrongLocationList do append logLines ("  ! " + f)
            )
            else append logLines ("Outside project      : 0")

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

            -- Logique pour passer à l'étape 2 ou 3
            if (missingMaps + relativeMaps) == 0 then
            (
                if wrongLocationMaps > 0 then
                (
                    setStep 2 "RELINK LOCAL\n(OUTSIDE MAPS)"
                    chk_fixOutside.visible = true
                    btn_main.enabled = true
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
                if wrongLocationMaps > 0 do chk_fixOutside.visible = true
                btn_force.enabled = true
                btn_force.visible = true
                btn_main.enabled = true
            )
        )

        -- ÉTAPE 2 : RELINK
        fn doStep2_Relink =
        (
            local logLines = #()
            append logLines "Auto-relinking..."
            setLog logLines

            -- On passe l'état de la case à cocher à la fonction de relink
            local result  = relinkBitmaps (chk_fixOutside.checked)
            local fixedCount   = result[1]
            local missingCount = result[2]

            chk_fixOutside.visible = false

            collectAllBitmaps()
            local stillMissing = 0
            local stillOutside = 0
            local scenePath = toLower maxFilePath
            
            -- Re-vérification post-relink
            for b in bitmapList do
            (
                local st = checkBitmapStatus b
                if st == "MISSING" or st == "RELATIVE" then stillMissing += 1
                else if st == "OK" and scenePath != "" do
                (
                    local fname = ""
                    try( fname = b.filename )catch()
                    if fname != undefined and fname != "" do
                    (
                        if (findString (toLower fname) scenePath) == undefined do stillOutside += 1
                    )
                )
            )

            append logLines ("Maps relinked / fixed : " + fixedCount as string)
            append logLines ("Still missing / relative : " + stillMissing as string)
            if stillOutside > 0 do append logLines ("Still outside project  : " + stillOutside as string)
            append logLines ""

            if stillMissing == 0 then
            (
                if stillOutside > 0 then
                (
                    append logLines "No missing maps, but some remain outside."
                    setLog logLines
                    setStep 3 "MAPS OK\n⚠ CHECK PATHS"
                )
                else
                (
                    append logLines "All maps resolved and in project !"
                    setLog logLines
                    setStep 3 "ALL MAPS\nOK ✓"
                )
                btn_main.enabled = false
                btn_force.visible = false
            )
            else
            (
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
                messageBox ("Relink terminé.\n" + fixedCount as string + " fixé(s), " + stillMissing as string + " toujours manquant(s).") title:"MaxStack - Relink Result"
            )
        )

        -- EVENTS
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
            ATSOps.visible = true
            atsops.refresh()
        )
    )

    CreateDialog rlMapChecker style:#(#style_titlebar, #style_sysmenu, #style_resizing)
