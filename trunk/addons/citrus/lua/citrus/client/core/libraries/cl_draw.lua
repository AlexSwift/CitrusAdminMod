--[[
Name: "cl_draw.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Draw = {}

-- Texture.
function citrus.Draw.Texture(Texture, X, Y, Width, Height, TextureColor)
	surface.SetTexture(Texture)
	
	-- Check Texture Color.
	if (TextureColor) then
		surface.SetDrawColor(TextureColor.r, TextureColor.g, TextureColor.b, TextureColor.a)
	else
		surface.SetDrawColor(255, 255, 255, 255)
	end
	
	-- Draw Textured Rect.
	surface.DrawTexturedRect(X, Y, Width, Height) 	
end

-- Rounded Text Box.
function citrus.Draw.RoundedTextBox(Text, TextFont, TextColor, X, Y, CornerSize, BackgroundColor, Title, TitleColor, CenterX, CenterY, Callback)
	Text = citrus.Utilities.GetTable(Text)
	
	-- Amount.
	local Amount = table.Count(Text)
	
	-- Text Width.
	local TextWidth, TextHeight = citrus.Utilities.GetMaximumTextSize(Text, TextFont)
	local Width, Height = TextWidth + 16, (TextHeight * Amount) + 16
	
	-- Check Title.
	if (Title) then
		TitleColor = TitleColor or TextColor
		
		-- Text Width.
		local TextWidth, TextHeight = citrus.Utilities.GetMaximumTextSize(Title, TextFont)
		
		-- Check Text Width.
		if (TextWidth + 16 > Width) then Width = TextWidth + 16 end
		
		-- Height.
		Height = Height + TextHeight
	end
	
	-- Check Center X.
	if (CenterX) then X = X - (Width / 2) end
	if (CenterY) then Y = Y - (Height / 2) end
	
	-- Check Callback.
	if (Callback) then X, Y = Callback(X, Y, Width, Height) end

	-- Rounded Box.
	draw.RoundedBox(CornerSize, X, Y, Width, Height, BackgroundColor)
	
	-- Check Title.
	if (Title) then
		Y = Y + TextHeight
		
		-- Check Draw Text.
		draw.SimpleText(Title, TextFont, X + (Width / 2), Y, TitleColor, 1, 1)
	else
		if (Amount == 1) then Y = Y + 1 end
	end
	
	-- For Loop.
	for K, V in pairs(Text) do
		Y = Y + TextHeight
		
		-- Check Draw Text.
		draw.SimpleText(V, TextFont, X + (Width / 2), Y, TextColor, 1, 1)
	end
end