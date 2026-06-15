
    try( DestroyDialog rlFileChecker )catch()

    -- ===========================================================
    -- FILENAME CLEANER — PURE FUNCTIONS
    -- ===========================================================

    -- Retourne le nom nettoyé ET un flag corona (true/false)
    fn cleanMaxFileName rawName =
    (
        local s = rawName
        local hasCorona = false
        local sLow = toLower s

        -- 1. DÉTECTION FLAG CORONA
        if (findString sLow "corona") != undefined then hasCorona = true

        if (findString sLow "_cr") != undefined then
        (
            local pos = findString sLow "_cr"
            while pos != undefined do
            (
                local afterPos = pos + 3
                local charAfter = if afterPos <= sLow.count then substring sLow afterPos 1 else ""
                if charAfter == "" or charAfter == "_" or charAfter == "-" or charAfter == " " or
                   (charAfter >= "0" and charAfter <= "9") then hasCorona = true
                pos = findString sLow "_cr" (pos + 1)
            )
        )
        if (findString sLow "-cr") != undefined then
        (
            local pos = findString sLow "-cr"
            while pos != undefined do
            (
                local afterPos = pos + 3
                local charAfter = if afterPos <= sLow.count then substring sLow afterPos 1 else ""
                if charAfter == "" or charAfter == "_" or charAfter == "-" or charAfter == " " or
                   (charAfter >= "0" and charAfter <= "9") then hasCorona = true
                pos = findString sLow "-cr" (pos + 1)
            )
        )

        -- 2. SUPPRESSION DES ANNÉES
        fn removeYear str =
        (
            local result = str
            local i = 1
            while i <= result.count do
            (
                local c = substring result i 1

                if c == "_" or c == "-" or c == " " then
                (
                    if i + 4 <= result.count then
                    (
                        local d1 = substring result (i+1) 1
                        local d2 = substring result (i+2) 1
                        local d3 = substring result (i+3) 1
                        local d4 = substring result (i+4) 1
                        local isYear = ((d1 == "1" and d2 == "9") or (d1 == "2" and d2 == "0")) and
                                       (d3 >= "0" and d3 <= "9") and (d4 >= "0" and d4 <= "9")
                        if isYear then
                        (
                            local after = if (i+5) <= result.count then substring result (i+5) 1 else ""
                            local isEnd = (after == "" or after == "_" or after == "-" or after == " ")
                            if isEnd then
                            (
                                local before = substring result 1 (i-1)
                                local rest   = if (i+4) < result.count then substring result (i+5) -1 else ""
                                result = before + rest
                            )
                            else i += 1
                        )
                        else i += 1
                    )
                    else i += 1
                )
                else if (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") then
                (
                    if i + 4 <= result.count then
                    (
                        local d1 = substring result (i+1) 1
                        local d2 = substring result (i+2) 1
                        local d3 = substring result (i+3) 1
                        local d4 = substring result (i+4) 1
                        local isYear = ((d1 == "1" and d2 == "9") or (d1 == "2" and d2 == "0")) and
                                       (d3 >= "0" and d3 <= "9") and (d4 >= "0" and d4 <= "9")
                        if isYear then
                        (
                            local after = if (i+5) <= result.count then substring result (i+5) 1 else ""
                            local isEnd = (after == "" or after == "_" or after == "-" or after == " ")
                            if isEnd then
                            (
                                local before = substring result 1 i
                                local rest   = if (i+4) < result.count then substring result (i+5) -1 else ""
                                result = before + rest
                            )
                            else i += 1
                        )
                        else i += 1
                    )
                    else i += 1
                )
                else i += 1
            )
            return result
        )
        s = removeYear s

        -- 3. SUPPRESSION CORONARENDER
        local coronarenderVariants = #(
            "_CoronaRender", "-CoronaRender", " CoronaRender", "(CoronaRender)",
            "_coronarender", "-coronarender", " coronarender", "(coronarender)",
            "_CORONARENDER", "-CORONARENDER", " CORONARENDER", "(CORONARENDER)",
            "CoronaRender", "coronarender", "CORONARENDER"
        )
        for v in coronarenderVariants do s = substituteString s v ""

        -- 4. SUPPRESSION CORONA
        local coronaVariants = #(
            "(Corona)", "(corona)", "(CORONA)",
            "_Corona",  "-Corona",  " Corona",
            "_corona",  "-corona",  " corona",
            "_CORONA",  "-CORONA",  " CORONA",
            "Corona",   "corona",   "CORONA"
        )
        for v in coronaVariants do s = substituteString s v ""

        -- 5. SUPPRESSION _cr / -cr
        local crVariants = #("_CR", "-CR", "_cr", "-cr", "_Cr", "-Cr")
        for v in crVariants do s = substituteString s v ""

        -- 6. SUPPRESSION VRAY
        local vrayVariants = #(
            "_VRay",   "-VRay",   " VRay",   "(VRay)",
            "_vray",   "-vray",   " vray",   "(vray)",
            "_VRAY",   "-VRAY",   " VRAY",   "(VRAY)",
            "_Vray",   "-Vray",   " Vray",   "(Vray)",
            "_VRayMtl","-VRayMtl"," VRayMtl",
            "VRay",    "vray",    "VRAY",    "Vray"
        )
        for v in vrayVariants do s = substituteString s v ""

        -- 7. NETTOYER SÉPARATEURS ORPHELINS
        local prevS = ""
        while prevS != s do
        (
            prevS = s
            s = substituteString s "__" "_"
        )
        prevS = ""
        while prevS != s do
        (
            prevS = s
            s = substituteString s "--" "-"
        )
        while s.count > 0 do
        (
            local last = substring s s.count 1
            if last == "_" or last == "-" or last == " " then s = substring s 1 (s.count - 1)
            else exit
        )
        while s.count > 0 do
        (
            local first = substring s 1 1
            if first == "_" or first == "-" or first == " " then s = substring s 2 -1
            else exit
        )

        -- 8. AJOUTER _corona
        if hasCorona then s = s + "_corona"

        return #(s, hasCorona)
    )

    -- Renomme le fichier .max sur disque avec gestion de la casse
    fn doRenameOnDisk oldPath newBaseName =
    (
        local dir    = getFilenamePath  oldPath
        local oldExt = getFilenameType  oldPath
        local newPath = dir + newBaseName + oldExt

        -- Vérification sensible à la casse (Case-Sensitive)
        local isExactSame = (oldPath.count == newPath.count and matchPattern oldPath pattern:newPath ignoreCase:false)
        if isExactSame then return #(true, "unchanged")

        -- Si c'est le même nom mais pas la même casse (ex: CORONA vs corona)
        -- MAXScript et Windows "ignorent" la casse par défaut, donc oldPath == newPath sera vrai
        if (toLower oldPath) == (toLower newPath) then
        (
            local tempPath = dir + newBaseName + "_TEMP" + oldExt
            renameFile oldPath tempPath -- Renommage temporaire
            if (renameFile tempPath newPath) then
                return #(true, newPath)
            else
                return #(false, "Case-only rename failed (temp file step error).")
        )

        -- Si le nom est différent, on vérifie d'abord que la destination n'existe pas déjà
        if doesFileExist newPath then
            return #(false, "A file with that name already exists:\n" + newPath)

        -- Renommage standard
        if (renameFile oldPath newPath) then
            return #(true, newPath)
        else
            return #(false, "renameFile failed — check write permissions.")
    )

    -- ===========================================================
    -- ROLLOUT
    -- ===========================================================
    rollout rlFileChecker "MaxStack — File Checker" width:420 height:520
    (
        listBox lst_log "" pos:[10,18] width:400 height:12
        label lbl_sep2  "__________________________________________________________________" pos:[10,192] width:400 height:12

        label lbl_prev_title "Preview :" pos:[10,208] width:400 height:16
        edittext edt_before "" pos:[10,228] width:400 height:22 readOnly:true
        label lbl_arrow "▼" pos:[195,254] width:30 height:18 align:#center
        edittext edt_after  "" pos:[10,274] width:400 height:22 readOnly:true

        label lbl_sep3  "__________________________________________________________________" pos:[10,302] width:400 height:12

        -- Boutons superposés
        button btn_main "CHECK\nFILENAME" pos:[140,350] width:120 height:120 align:#center
        button btn_confirm "RENAME FILE\nON DISK" pos:[140,350] width:120 height:120 visible:false

        local step         = 1
        local cleanedName  = ""
        local hasCoronaFlag = false

        fn setLog lines = ( lst_log.items = lines )

        on rlFileChecker open do
        (
            setLog #("Ready.", "Current file : " + (if maxFileName == "" then "(not saved)" else maxFileName))
            edt_before.text = ""
            edt_after.text  = ""
        )

        on btn_main pressed do
        (
            if step == 1 then
            (
                if maxFileName == "" then
                (
                    setLog #("ERROR : File not saved yet.", "Please save your .max file first.")
                    return false
                )

                local rawBase = getFilenameFile maxFileName
                local result  = cleanMaxFileName rawBase
                cleanedName   = result[1]
                hasCoronaFlag  = result[2]

                local logLines = #()
                append logLines ("File   : " + maxFileName)
                append logLines ("Path   : " + maxFilePath)
                append logLines ""

                local raw = rawBase
                local rawLow = toLower raw
                local hasVray = (findString rawLow "vray") != undefined
                if hasVray then append logLines "⚠  VRay detected → will be removed"

                if hasCoronaFlag then append logLines "✓  Corona detected → will become _corona suffix"

                local hasYear = false
                for yearSep in #("_", "-", " ") do (
                    for yearPfx in #("19", "20") do (
                        local yp = findString raw (yearSep + yearPfx)
                        if yp != undefined then (
                            local p2 = yp + 3
                            if p2 + 1 <= raw.count then (
                                local c1 = substring raw p2 1
                                local c2 = substring raw (p2+1) 1
                                if (c1 >= "0" and c1 <= "9") and (c2 >= "0" and c2 <= "9") then hasYear = true
                            )
                        )
                    )
                )
                if hasYear then append logLines "✓  Year detected → will be removed"

                -- Vérification "Déjà propre" Sensible à la casse
                local isAlreadyClean = (cleanedName.count == rawBase.count and matchPattern cleanedName pattern:rawBase ignoreCase:false)
                
                if isAlreadyClean then
                (
                    append logLines ""
                    append logLines "✔  Filename is already clean. Nothing to do."
                    setLog logLines
                    edt_before.text = rawBase
                    edt_after.text  = cleanedName
                    btn_main.text   = "ALREADY\nCLEAN ✔"
                    btn_main.enabled = false
                    step = 3
                    return true
                )

                append logLines ""
                append logLines "Review the rename below, then confirm."
                setLog logLines

                edt_before.text = rawBase
                edt_after.text  = cleanedName

                -- On cache btn_main et on affiche btn_confirm
                btn_main.visible = false
                btn_confirm.visible = true
                step = 2
            )
        )

        on btn_confirm pressed do
        (
            if step == 2 then
            (
                local fullPath = maxFilePath + maxFileName
                local result   = doRenameOnDisk fullPath cleanedName

                if result[1] == true then
                (
                    if result[2] == "unchanged" then
                    (
                        setLog #("File was already correctly named.", "Nothing changed.")
                    )
                    else
                    (
                        local newFull = result[2]
                        local reloaded = loadMaxFile newFull useFileUnits:true quiet:true
                        if reloaded then
                        (
                            setLog #(
                                "✔  File renamed successfully.",
                                "",
                                "New name : " + (getFilenameFile newFull) + ".max",
                                "Path     : " + (getFilenamePath newFull),
                                "",
                                "File reloaded in 3ds Max."
                            )
                        )
                        else
                        (
                            setLog #(
                                "✔  File renamed on disk.",
                                "⚠  Could not auto-reload — please reopen manually:",
                                newFull
                            )
                        )
                    )

                    -- On cache btn_confirm et on restaure btn_main avec son nouvel état "Terminé"
                    btn_confirm.visible = false
                    btn_main.visible = true
                    btn_main.enabled = false
                    btn_main.text    = "RENAME\nDONE ✔"
                    step = 3
                )
                else
                (
                    setLog #("ERROR renaming file :", result[2])
                )
            )
        )
    )

    CreateDialog rlFileChecker style:#(#style_titlebar, #style_sysmenu)
