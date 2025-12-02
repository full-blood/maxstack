macroscript Material_PasteClipboardImg
toolTip:"Paste Clipboard Image"
category:"MyTools"
(
try(DestroyDialog pastClipboardImg)catch()

rollout pastClipboardImg "Paste Clipboard Image" width:220 height:110 (
	
	button 'btn1' "Paste to object(s) with new material" pos:[10,10] width:200 height:40 align:#left
	button 'btn2' "Paste to Material Editor's current view" pos:[10,60] width:200 height:40 align:#left
	
	fn PropBitmap = (
		undo on (
		if selection.count == 1 then (
			resetxform $
			maxOps.CollapseNode $ off
			global bitmg = "" as string
			try(bitmg = (sceneMaterials[$.material.name].texmapDiffuse.filename) as string)catch()
			try(bitmg = (sceneMaterials[$.material.name].base_color_map.bitmap) as string )catch()
			bitmg = bitmg as string
			wordTofind = "BitMap"
			StrPlace = findString bitmg wordTofind
			if StrPlace != undefined then (bitmg = substring bitmg (wordTofind.count+2) -1)
			print bitmg
				

			-- bitmg = (sceneMaterials[$.material.name].texmapDiffuse.filename) as string
			try(global img = (dotNetClass "System.Drawing.Image").FromFile bitmg)catch(messageBox "no image found")
			format "image width : % / height : %\n" img.Width img.Height
			prop = (img.Width as float) / (img.Height as float)
			height = ($.max - $.min).y
			Nwidth = height*prop
			width = ($.max - $.min).x
			Nwidth = Nwidth/width
			$.scale = [Nwidth, 1, 1]
		)else (messageBox "please select one plane")
		)
	)
	fn getClipboardImg = (
		-- Load .NET assemblies
		dotNet.loadAssembly "System.Windows.Forms"
		dotNet.loadAssembly "System.Drawing"

		-- Get image from clipboard
		global clipImage = (dotNetClass "System.Windows.Forms.Clipboard").GetImage()
		
		if clipImage != undefined then
		(
			-- Convert the .NET image to a Max bitmap
			width = clipImage.Width
			height = clipImage.Height

			-- Create a MaxScript bitmap
			randomName = random 1 999999 
			randomName = randomName as string
			maxBmp = bitmap width height filename:("fromClipboard"+randomName+".png")

			-- Create a graphics object from the bitmap
			g = (dotNetClass "System.Drawing.Graphics").FromImage (dotNetObject "System.Drawing.Bitmap" width height)

			-- Draw the clipboard image into the bitmap
			g.DrawImage clipImage (dotNetObject "System.Drawing.Rectangle" 0 0 width height)

			-- Save to disk
-- 			imgPath = getDir #temp + "\\clipboard_image"+randomName+".png"
			imgPath = maxFilePath + "\\4_Textures" + "\\clipboard_image"+randomName+".png"
			clipImage.Save imgPath (dotNetClass "System.Drawing.Imaging.ImageFormat").png

			-- Load the saved image into a Max bitmap
			maxBmp = openBitmap imgPath
			global bm = openBitMap imgPath
			print bm
			global bmt = bitmapTexture()
			bmt.bitmap = bm
		)
		else
		(
			print "No image found in clipboard."
		)
	)
	on pastClipboardImg open do (
		getClipboardImg()
	)
	on btn1 pressed do (
		randomName = random 1 9999999999999
		randomName = "mat_"+(randomName as string)
		newMaterial = CoronaLegacyMtl name:randomName diffuse:(color 0 0 0)
		newMaterial.texmapDiffuse = bmt
		undo "new temp material" on (
		for i in selection do (
			i.mat = newMaterial
		))
		PropBitmap()
	)
	on btn2 pressed do (
		sme.Open()
		actIndex = sme.activeview
		theView = sme.getview actIndex

		local viewSize = theView.position
		local centerX = viewSize.x / 2
		local centerY = viewSize.y / 2

		theView.createnode bmt (point2 centerX centerY)
	)
)
CreateDialog pastClipboardImg
)