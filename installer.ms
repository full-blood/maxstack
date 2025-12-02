fn updateMaxStack =
(
	try (
		local root = (getDir #userScripts) + "\MaxStack"

		if not doesFileExist root do makeDir root
		if not doesFileExist (root + "\\icons") do makeDir (root + "\\icons")
		if not doesFileExist (root + "\\update") do makeDir (root + "\\update")
		if not doesFileExist (root + "\\scripts") do makeDir (root + "\\scripts")

		-- Copier tous les fichiers depuis le dossier où l’installateur est lancé
		local installerDir = getFilenamePath (getSourceFileName())

		copyFile (installerDir + "main.ms") (root + "\\main.ms")
		copyFile (installerDir + "version.txt") (root + "\\version.txt")
		copyFile (installerDir + "update\\update.ms") (root + "\\update\\update.ms")
		copyFile (installerDir + "icons\\close.png") (root + "\\icons\\close.png")

		-- Copier tous les scripts
		local scripts = getFiles (installerDir + "scripts\\*.ms")
		for s in scripts do copyFile s (root + "\\scripts\\" + (getFilenameFile s + ".ms"))

		-- Copier tous les scripts
		local icones = getFiles (installerDir + "icons\\*.png")
		for ic in icons do copyFile s (root + "\\icons\\" + (getFilenameFile ic + ".png"))

		messageBox "MaxStack installé."
	)
	catch (
		messageBox "Erreur installation MaxStack."
	)
)

updateMaxStack