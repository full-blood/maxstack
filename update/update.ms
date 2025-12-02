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

fn checkForUpdate toolDir =
(
    local versionLocal = trimRight (readFile (toolDir + "/version.txt")) "\n\r"
    local remoteVersionURL = "https://raw.githubusercontent.com/full-blood/maxstack/main/version.txt"
    local versionRemote = trimRight (getRemoteText remoteVersionURL) "\n\r"

    if versionLocal != versionRemote then
    (
        local updateURL = "https://raw.githubusercontent.com/full-blood/maxstack/main/main.ms"
        downloadFile updateURL (toolDir + "/main.ms")

        local localVersionFile = createFile (toolDir + "/version.txt")
        format versionRemote to:localVersionFile
        close localVersionFile

        messageBox ("MaxStack a été mis à jour en version " + versionRemote)
    )
)
