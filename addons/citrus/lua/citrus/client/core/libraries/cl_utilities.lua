--[[
Name: "cl_utilities.lua".
Product: "Citrus (Server Management)".
--]]

function citrus.Utilities.GetTeamColor(Player)
	local Team = Player:Team()
	
	-- return Get Color.
	return team.GetColor(Team)
end

-- Is File Downloaded.
function citrus.Utilities.IsFileDownloaded(File)
	if (file.Exists("../lua_temp/"..File) or file.Exists("../lua/"..File)) then
		return true
	else
		return false
	end
end

-- Key Value Receive.
function citrus.Utilities.KeyValueReceive(Message, Table)
	local Key = Message:ReadString()
	local Type = Message:ReadChar()
	
	-- Table.
	Table = Table or {}
	
	-- Check Type.
	if (Type == 1) then Table[Key] = Message:ReadEntity()
	elseif (Type == 2) then
		local String = Message:ReadString()
		
		-- Check Key.
		if (Table[Key]) then
			if (type(Table[Key]) == "string") then Table[Key] = Table[Key]..String end
		end
		
		-- Check Key.
		if (!Table[Key]) then Table[Key] = String end
	elseif (Type == 3) then Table[Key] = Message:ReadFloat()
	elseif (Type == 4) then Table[Key] = Message:ReadChar()
	elseif (Type == 5) then Table[Key] = Message:ReadShort()
	elseif (Type == 6) then Table[Key] = Message:ReadLong()
	elseif (Type == 7) then Table[Key] = Message:ReadBool()
	elseif (Type == 8) then Table[Key] = Message:ReadVector()
	elseif (Type == 9) then Table[Key] = Message:ReadAngle() end
	
	-- Return Key.
	return Table[Key]
end

-- Get Maximum Text Size.
function citrus.Utilities.GetMaximumTextSize(Text, TextFont)
	Text = citrus.Utilities.GetTable(Text)
	
	-- Set Font.
	surface.SetFont(TextFont)
	
	-- Text Width.
	local TextWidth, TextHeight = surface.GetTextSize("M")
	
	-- For Loop.
	for K, V in pairs(Text) do
		local Width, Height = surface.GetTextSize(V)
		
		-- Check Width.
		if (Width > TextWidth) then TextWidth = Width end
		if (Height > TextHeight) then TextHeight = Height end
	end
	
	-- Return Text Width.
	return TextWidth, TextHeight
end