try (
    local root = (getDir #userScripts) + "/MaxStack"

    if not doesFileExist root do makeDir root
    if not doesFileExist (root + "/icons") do makeDir (root + "/icons")
    if not doesFileExist (root + "/update") do makeDir (root + "/update")

    copyFile (getSourceFileName()) (root + "/installer.ms")

    -- Fichiers principaux
    if doesFileExist @"$installpath\main.ms" do
        copyFile @"$installpath\main.ms" (root + "/main.ms")

    if doesFileExist @"$installpath\version.txt" do
        copyFile @"$installpath\version.txt" (root + "/version.txt")

    -- Update
    if doesFileExist @"$installpath\update\update.ms" do
        copyFile @"$installpath\update\update.ms" (root + "/update/update.ms")

    -- Icônes
    if doesFileExist @"$installpath\icons\close.png" do
        copyFile @"$installpath\icons\close.png" (root + "/icons/close.png")

    messageBox "MaxStack installé avec succès."
) catch (
    messageBox "Erreur lors de l’installation."
)
