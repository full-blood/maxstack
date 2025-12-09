fn getRemoteText url =
(
    local client = dotNetObject "System.Net.WebClient"
    client.Encoding = dotNetClass "System.Text.Encoding".UTF8
    client.DownloadString url
)

fn downloadFile url dest =
(
    local client = dotNetObject "System.Net.WebClient"
    client.DownloadFile url dest
)

fn checkForUpdate root =
(
    versionLocal = trimRight (readFile (root + "/version.txt")) "\n\r"
    remoteVersionURL = "https://raw.githubusercontent.com/full-blood/maxstack/main/version.txt"
    versionRemote = trimRight (getRemoteText remoteVersionURL) "\n\r"

    if versionLocal != versionRemote then
    (
        -- Mise à jour de main.ms
        downloadFile "https://raw.githubusercontent.com/full-blood/maxstack/main/main.ms" (root + "/main.ms")

        -- Mise à jour des scripts
        local remoteScriptList = getRemoteText "https://raw.githubusercontent.com/full-blood/maxstack/main/scripts/list.txt"
        local scriptsDir = root + "/scripts"

        for ln in filterString remoteScriptList "\n" do
        (
            local scriptName = trimRight ln "\r"
            if scriptName != "" do
            (
                local url = "https://raw.githubusercontent.com/full-blood/maxstack/main/scripts/" + scriptName
                local localPath = scriptsDir + "/" + scriptName
                downloadFile url localPath
            )
        )

        -- Mettre à jour version.txt
        local f = createFile (root + "/version.txt")
        format versionRemote to:f
        close f

        messageBox ("MaxStack mis à jour en version " + versionRemote)
    )
)
