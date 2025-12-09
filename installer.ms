fn deleteAllFilesRecursively folderPath =
(
    try (
        -- Supprime tous les fichiers du dossier
        files = getFiles (folderPath + "\\*.*")
        for f in files do
        (
            deleteFile f
        )

        -- Parcours récursif des sous-dossiers
        subFolders = getDirectories (folderPath + "\\*.*")
        for sub in subFolders do
        (
            deleteAllFilesRecursively sub
        )
    ) catch e (
        format "Erreur lors de la suppression dans % : %\n" folderPath e
    )
)

fn updateMaxStack =
(
	try (
		root = (getDir #userScripts) + "\MaxStack"
		try(deleteAllFilesRecursively root)
		catch()

		if not doesFileExist root do makeDir root
		if not doesFileExist (root + "\\icons") do makeDir (root + "\\icons")
		if not doesFileExist (root + "\\update") do makeDir (root + "\\update")
		if not doesFileExist (root + "\\scripts") do makeDir (root + "\\scripts")

		-- Copier tous les fichiers depuis le dossier où l’installateur est lancé
		installerDir = getFilenamePath (getSourceFileName())

		copyFile (installerDir + "main.ms") (root + "\\main.ms")
		copyFile (installerDir + "version.txt") (root + "\\version.txt")
		copyFile (installerDir + "update\\update.ms") (root + "\\update\\update.ms")
		copyFile (installerDir + "icons\\close.png") (root + "\\icons\\close.png")

		-- Copier tous les scripts
		scripts = getFiles (installerDir + "scripts\\*.ms")
		for s in scripts do copyFile s (root + "\\scripts\\" + (getFilenameFile s + ".ms"))

		-- Copier toutes les icones
		icons = getFiles (installerDir + "icons\\*.png")
		for ic in icons do copyFile ic (root + "\\icons\\" + (getFilenameFile ic + ".png"))

		messageBox "MaxStack installé."
	)
	catch (
		messageBox ("Erreur installation MaxStack.")
	)
)

updateMaxStack()