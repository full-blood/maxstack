macroScript MaxStack_About category:"MaxStack" tooltip:"À propos de MaxStack"
(
    -- -----------------------------------------------
    -- Config
    -- -----------------------------------------------
    local githubUser    = "TON_USERNAME"
    local githubRepo    = "TON_REPO"
    local branch        = "main"
    local baseRawURL    = "https://raw.githubusercontent.com/" + githubUser + "/" + githubRepo + "/" + branch + "/"
    local releasesURL   = "https://github.com/" + githubUser + "/" + githubRepo + "/releases/latest"

    -- -----------------------------------------------
    -- Version locale
    -- -----------------------------------------------
    local root        = (getDir #userScripts) + "\\MaxStack"
    local versionFile = root + "\\version.txt"
    local localVer    = "0.0.0"

    if doesFileExist versionFile then (
        local f = openFile versionFile mode:"r"
        localVer = trimRight (readLine f)
        close f
    )

    -- -----------------------------------------------
    -- Version distante via GitHub raw
    -- -----------------------------------------------
    local remoteVer   = ""
    local fetchOK     = false

    try (
        local http = dotNetObject "System.Net.WebClient"
        http.Headers.Add "User-Agent" "MaxScript"
        remoteVer = trimRight (http.DownloadString (baseRawURL + "version.txt"))
        fetchOK   = true
    ) catch (
        remoteVer = ""
    )

    -- -----------------------------------------------
    -- Comparaison simple (string suffisant si semver x.y.z)
    -- -----------------------------------------------
    local updateAvail = fetchOK and (remoteVer != "") and (remoteVer != localVer)

    -- -----------------------------------------------
    -- UI
    -- -----------------------------------------------
    local msg = "MaxStack v" + localVer + "\n\nGestionnaire de scripts automatisé.\n\n"

    if not fetchOK then
        msg += "⚠ Impossible de vérifier les mises à jour (pas de connexion ?)."
    else if updateAvail then
        msg += "🔔 Mise à jour disponible : v" + remoteVer + "\n(cliquez OK pour installer)"
    else
        msg += "✔ Vous avez la dernière version."

    -- Bouton OK / Annuler seulement si update dispo
    local doUpdate = false
    if updateAvail then (
        doUpdate = (queryBox msg title:"MaxStack" beep:false)
    ) else (
        messageBox msg title:"MaxStack"
    )

    -- -----------------------------------------------
    -- Auto-update : télécharge le .mzp et le run
    -- -----------------------------------------------
    if doUpdate then (
        try (
            local http     = dotNetObject "System.Net.WebClient"
            http.Headers.Add "User-Agent" "MaxScript"
            local tempDir  = getDir #temp
            local mzpPath  = tempDir + "\\MaxStack_update.mzp"

            -- Télécharge le .mzp depuis GitHub Releases (asset direct)
            local mzpURL = "https://github.com/" + githubUser + "/" + githubRepo + "/releases/latest/download/MaxStack.mzp"
            http.DownloadFile mzpURL mzpPath

            if doesFileExist mzpPath then (
                -- Lance l'installation MZP native de 3ds Max
                installPkg mzpPath
                messageBox ("MaxStack mis à jour vers v" + remoteVer + ".\nRelancez 3ds Max pour appliquer.") title:"MaxStack Update"
            ) else (
                messageBox "Téléchargement échoué. Essayez manuellement :\n" + releasesURL title:"Erreur"
            )
        ) catch (
            messageBox ("Erreur lors du téléchargement :\n" + (getCurrentException()) + "\n\nLien manuel :\n" + releasesURL) title:"Erreur"
        )
    )
)