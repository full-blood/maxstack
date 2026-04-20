-- ===========================================================
-- FILENAME CLEANER — PURE FUNCTIONS
-- ===========================================================

-- Retourne le nom nettoyé ET un flag corona (true/false)
-- Input  : nom sans extension, ex "Dry-Plants32(Corona)_2021"
-- Output : struct { cleanName (string), hasCorona (bool) }
fn cleanMaxFileName rawName =
(
    local s = rawName

    -- -------------------------------------------------------
    -- 1. DÉTECTION FLAG CORONA (avant de tout effacer)
    --    Variantes : corona, Corona, CORONA, coronarender,
    --    CoronaRender, (Corona), -corona, _corona, cr, CR
    --    quand précédé de _ ou -
    -- -------------------------------------------------------
    local hasCorona = false

    -- On travaille sur une version lowercase pour la détection uniquement
    local sLow = toLower s

    -- "corona" ou "coronarender" n'importe où dans le nom
    if (findString sLow "corona") != undefined then hasCorona = true

    -- _cr  -cr  en tant que token (pas juste des lettres au milieu d'un mot)
    -- on cherche le pattern dans la version lowercase
    if (findString sLow "_cr") != undefined then
    (
        -- s'assurer que c'est bien un token et pas "acrobat", "micro", etc.
        local pos = findString sLow "_cr"
        while pos != undefined do
        (
            local afterPos = pos + 3
            local charAfter = if afterPos <= sLow.count then substring sLow afterPos 1 else ""
            -- token valide si suivi de fin de chaîne, d'un _, d'un - ou d'un chiffre
            if charAfter == "" or charAfter == "_" or charAfter == "-" or charAfter == " " or
               (charAfter >= "0" and charAfter <= "9") then
                hasCorona = true
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
               (charAfter >= "0" and charAfter <= "9") then
                hasCorona = true
            pos = findString sLow "-cr" (pos + 1)
        )
    )

    -- -------------------------------------------------------
    -- 2. SUPPRESSION DES ANNÉES EN PREMIER
    --    Cas 1 : séparateur + 4 chiffres  ex: _2013  -2019  (2021)
    --    Cas 2 : année collée à un mot-clé ex: vray2013  corona2021
    --    On supprime dans les deux cas.
    -- -------------------------------------------------------
    fn removeYear str =
    (
        local result = str
        local i = 1
        while i <= result.count do
        (
            local c = substring result i 1

            -- CAS 1 : séparateur (_ - espace) précède l'année
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
                            -- ne pas avancer : re-tester la même position
                        )
                        else i += 1
                    )
                    else i += 1
                )
                else i += 1
            )

            -- CAS 2 : année collée sans séparateur (ex: vray2013, corona2021)
            -- On cherche une lettre suivie directement de 4 chiffres année
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
                            -- supprime uniquement les 4 chiffres (pas la lettre avant)
                            local before = substring result 1 i
                            local rest   = if (i+4) < result.count then substring result (i+5) -1 else ""
                            result = before + rest
                            -- ne pas avancer i
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

    -- -------------------------------------------------------
    -- 3. SUPPRESSION CORONARENDER (avant corona pour éviter
    --    de laisser "render" orphelin)
    -- -------------------------------------------------------
    local coronarenderVariants = #(
        "_CoronaRender", "-CoronaRender", " CoronaRender", "(CoronaRender)",
        "_coronarender", "-coronarender", " coronarender", "(coronarender)",
        "_CORONARENDER", "-CORONARENDER", " CORONARENDER", "(CORONARENDER)",
        "CoronaRender", "coronarender", "CORONARENDER"
    )
    for v in coronarenderVariants do s = substituteString s v ""

    -- -------------------------------------------------------
    -- 4. SUPPRESSION CORONA (toutes variantes)
    -- -------------------------------------------------------
    local coronaVariants = #(
        "(Corona)", "(corona)", "(CORONA)",
        "_Corona",  "-Corona",  " Corona",
        "_corona",  "-corona",  " corona",
        "_CORONA",  "-CORONA",  " CORONA",
        "Corona",   "corona",   "CORONA"
    )
    for v in coronaVariants do s = substituteString s v ""

    -- -------------------------------------------------------
    -- 5. SUPPRESSION _cr / -cr (flag déjà capturé)
    -- -------------------------------------------------------
    local crVariants = #(
        "_CR", "-CR", "_cr", "-cr",
        "_Cr", "-Cr"
    )
    for v in crVariants do s = substituteString s v ""

    -- -------------------------------------------------------
    -- 6. SUPPRESSION VRAY (toutes variantes, pas de flag)
    -- -------------------------------------------------------
    local vrayVariants = #(
        "_VRay",   "-VRay",   " VRay",   "(VRay)",
        "_vray",   "-vray",   " vray",   "(vray)",
        "_VRAY",   "-VRAY",   " VRAY",   "(VRAY)",
        "_Vray",   "-Vray",   " Vray",   "(Vray)",
        "_VRayMtl","-VRayMtl"," VRayMtl",
        "VRay",    "vray",    "VRAY",    "Vray"
    )
    for v in vrayVariants do s = substituteString s v ""

    -- -------------------------------------------------------
    -- 7. NETTOYER SÉPARATEURS ORPHELINS laissés par les
    --    suppressions (__, --, sep en début/fin).
    --    On ne touche PAS aux espaces ou tirets du nom d'origine.
    -- -------------------------------------------------------

    -- __ consécutifs → _
    local prevS = ""
    while prevS != s do
    (
        prevS = s
        s = substituteString s "__" "_"
    )
    -- -- consécutifs → -
    prevS = ""
    while prevS != s do
    (
        prevS = s
        s = substituteString s "--" "-"
    )
    -- Séparateur en fin de nom
    while s.count > 0 do
    (
        local last = substring s s.count 1
        if last == "_" or last == "-" or last == " " then
            s = substring s 1 (s.count - 1)
        else exit
    )
    -- Séparateur en début de nom
    while s.count > 0 do
    (
        local first = substring s 1 1
        if first == "_" or first == "-" or first == " " then
            s = substring s 2 -1
        else exit
    )

    -- -------------------------------------------------------
    -- 8. AJOUTER _corona SI FLAG DÉTECTÉ
    -- -------------------------------------------------------
    if hasCorona then s = s + "_corona"

    return #(s, hasCorona)
)

-- Construit le preview : "avant  →  après"
fn previewRename rawName =
(
    local result = cleanMaxFileName rawName
    local clean  = result[1]
    local flag   = result[2]
    return #(clean, flag)
)

-- Renomme le fichier .max sur disque + retourne le nouveau chemin complet
fn doRenameOnDisk oldPath newBaseName =
(
    local dir    = getFilenamePath  oldPath
    local oldExt = getFilenameType  oldPath   -- ".max"
    local newPath = dir + newBaseName + oldExt

    if oldPath == newPath then return #(true, "unchanged")

    if doesFileExist newPath then
        return #(false, "A file with that name already exists:\n" + newPath)

    if (renameFile oldPath newPath) then
        return #(true, newPath)
    else
        return #(false, "renameFile failed — check write permissions.")
)

-- ===========================================================
-- ROLLOUT
-- ===========================================================
try( DestroyDialog rlFileChecker )catch()

rollout rlFileChecker "MapStack — File Checker" width:420 height:520
(
    -- Header
    label lbl_title "FILE CHECKER" pos:[0,14]  width:420 height:20 align:#center
    label lbl_step  "Step 1 — Filename" pos:[0,36] width:420 height:16 align:#center
    label lbl_sep1  "______________________________________________" pos:[10,52] width:400 height:12

    -- Log
    listBox lst_log "" pos:[10,68] width:400 height:8

    label lbl_sep2  "______________________________________________" pos:[10,212] width:400 height:12

    -- Préview du résultat
    label lbl_prev_title "Preview :" pos:[10,228] width:400 height:16
    edittext edt_before "" pos:[10,248] width:400 height:22 readOnly:true
    label lbl_arrow "▼" pos:[195,274] width:30 height:18 align:#center
    edittext edt_after  "" pos:[10,294] width:400 height:22 readOnly:true

    label lbl_sep3  "______________________________________________" pos:[10,322] width:400 height:12

    -- Grand bouton central
    button btn_main "CHECK\nFILENAME" pos:[110,340] width:200 height:120 align:#center

    -- Bouton confirmer (visible seulement step 2)
    button btn_confirm "✓  RENAME FILE ON DISK" pos:[60,475] width:300 height:32 enabled:false visible:false

    -- État
    local step         = 1   -- 1:check  2:confirm  3:done
    local cleanedName  = ""
    local hasCoronaFlag = false

    -- -------------------------------------------------------
    fn setLog lines = ( lst_log.items = lines )

    -- -------------------------------------------------------
    on rlFileChecker open do
    (
        setLog #("Ready.", "Current file : " + (if maxFileName == "" then "(not saved)" else maxFileName))
        edt_before.text = ""
        edt_after.text  = ""
    )

    -- -------------------------------------------------------
    on btn_main pressed do
    (
        if step == 1 then
        (
            -- --- STEP 1 : analyser le nom actuel ---
            if maxFileName == "" then
            (
                setLog #("ERROR : File not saved yet.", "Please save your .max file first.")
                return false
            )

            local rawBase = getFilenameFile maxFileName  -- sans extension
            local result  = cleanMaxFileName rawBase
            cleanedName   = result[1]
            hasCoronaFlag  = result[2]

            local logLines = #()
            append logLines ("File   : " + maxFileName)
            append logLines ("Path   : " + maxFilePath)
            append logLines ""

            -- Diagnostics
            local raw = rawBase

            -- Vray ?
            local rawLow = toLower raw
            local hasVray = (findString rawLow "vray") != undefined
            if hasVray then append logLines "⚠  VRay detected → will be removed"

            -- Corona ?
            if hasCoronaFlag then append logLines "✓  Corona detected → will become _corona suffix"

            -- Années ?
            local hasYear = false
            for yearSep in #("_", "-", " ") do (
                for yearPfx in #("19", "20") do (
                    local yp = findString raw (yearSep + yearPfx)
                    if yp != undefined then (
                        local p2 = yp + 3
                        if p2 + 1 <= raw.count then (
                            local c1 = substring raw p2 1
                            local c2 = substring raw (p2+1) 1
                            if (c1 >= "0" and c1 <= "9") and (c2 >= "0" and c2 <= "9") then
                                hasYear = true
                        )
                    )
                )
            )
            if hasYear then append logLines "✓  Year detected → will be removed"

            -- Déjà propre ?
            if cleanedName == rawBase then
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

            -- Passer en mode confirmation
            btn_main.text     = "CHECK\nDONE"
            btn_main.enabled  = false
            btn_confirm.enabled = true
            btn_confirm.visible = true
            step = 2
        )
    )

    -- -------------------------------------------------------
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

                    -- Recharger le fichier dans 3ds Max pour mettre à jour maxFileName
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

                btn_confirm.enabled = false
                btn_main.text       = "RENAME\nDONE ✔"
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