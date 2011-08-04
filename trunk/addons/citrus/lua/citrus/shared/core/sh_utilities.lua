--[[
Name: "sh_utilities.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Utilities = {}

-- Get Formatted Time.
function citrus.Utilities.GetFormattedTime(Seconds, Format)
	local Table = {Hours = 0, Minutes = 0, Seconds = 0}
	
	-- Check Seconds.
	if (Seconds > 0) then
		Table.Hours = string.format("%02.f", math.floor(Seconds / 3600))
		Table.Minutes = string.format("%02.f", math.floor(Seconds / 60 - (Table.Hours * 60)))
		Table.Seconds = string.format("%02.f", math.floor(Seconds - Table.Hours * 3600 - Table.Minutes * 60))
	end
	
	-- Check Format.
	if (Format) then
		Format = string.Replace(Format, "%h", tostring(Table.Hours))
		Format = string.Replace(Format, "%m", tostring(Table.Minutes))
		Format = string.Replace(Format, "%s", tostring(Table.Seconds))
		
		-- Return Format.
		return Format
	end
	
	-- Return Hours.
	return Table.Hours..":"..Table.Minutes..":"..Table.Seconds
end

-- Player Trace.
function citrus.Utilities.PlayerTrace(Player)
	local Trace = util.GetPlayerTrace(Player)
	
	-- return Trace Line.
	return util.TraceLine(Trace)
end

-- Table Save.
function citrus.Utilities.TableSave(File, Table)
	local Contents = citrus.Serialise.Serialise(Table)
	
	-- Write.
	file.Write("citrus/"..File, citrus.Serialise.Serialise(Table))
end

-- Table Load.
function citrus.Utilities.TableLoad(File)
	if (file.Exists("citrus/"..File)) then
		return citrus.Serialise.Deserialise(file.Read("citrus/"..File))
	end
	
	-- Return False.
	return false
end

-- Get Variable.
function citrus.Utilities.GetVariable(String)
	local Exploded = string.Explode(".", String)
	
	-- Search.
	local function Search(Table, Contents, Function)
		local Key = Contents[1]
		
		-- Remove.
		table.remove(Contents, 1)
		
		-- Check Key.
		if (Table[Key]) then
			if (type(Table[Key]) == "table" and #Contents > 0) then
				return Search(Table[Key], Contents)
			else
				return Table[Key]
			end
		else
			return
		end
	end
	
	-- Return Search.
	return Search(_G, Exploded, Function)
end

-- Get Table.
function citrus.Utilities.GetTable(Value)
	local Type = type(Value)
	
	-- Check Type.
	if (Type != "table") then Value = {Value} end
	
	-- Return Value.
	return Value
end

-- Copy Missing Key Values.
function citrus.Utilities.CopyMissingKeyValues(Destination, Source)
	for K, V in pairs(Source) do
		if (type(V) == "table" and type(Destination[K]) == "table") then
			citrus.Utilities.CopyMissingKeyValues(Destination[K], V)
		else
			Destination[K] = Destination[K] or V
		end
	end
end

-- Get String Value.
function citrus.Utilities.GetStringValue(String)
	if (type(String) != "string") then return String end
	
	-- Number.
	local Number = tonumber(String)
	
	-- Check Number.
	if (Number) then return Number end
	
	-- Success.
	local Success, Boolean = citrus.Utilities.ToBoolean(String)
	
	-- Check Success.
	if (Success) then return Boolean end
	
	-- Return String.
	return String
end

-- To Boolean.
function citrus.Utilities.ToBoolean(String)
	local Boolean = nil
	
	-- Check Lower.
	if (string.lower(String) == "true" or String == "1" or String == 1) then Boolean = true end
	if (string.lower(String) == "false" or String == "0" or String == 0) then Boolean = false end
	
	-- Return Boolean.
	return (Boolean != nil), Boolean
end

-- Get Random String.
function citrus.Utilities.GetRandomString(Characters)
	local String = ""
	
	-- For Loop.
	for I = 1, Characters do String = String..string.char(math.random(97, 122)) end
	
	-- Return String.
	return String
end

-- Generate File Name.
function citrus.Utilities.GenerateFileName(Directory, Extension)
	local FileName = citrus.Utilities.GetRandomString(8)
	
	-- Check Exists.
	if (file.Exists(Directory..FileName..Extension)) then
		return citrus.Utilities.GenerateFileName(Directory, Extension)
	else
		return FileName
	end
end

-- Split.
function citrus.Utilities.Split(String, Characters)
	local Table = {}
	
	-- Split.
	local function Split(String, Characters, Table)
		if (string.len(String) > Characters) then
			Table[#Table + 1] = string.sub(String, 1 , Characters - 1)
			
			-- Split.
			Split(string.sub(String, Characters), Characters, Table)
		else
			Table[#Table + 1] = String
		end
	end
	
	-- Split.
	Split(String, Characters, Table)
	
	-- Return Table.
	return Table
end

-- Exploded.
function citrus.Utilities.Explode(String, Seperator)
	local Table = string.Explode(Seperator, String)
	
	-- For Loop.
	for K, V in pairs(Table) do
		Table[K] = string.Trim(V)
		
		-- Check V.
		if (V == "") then Table[K] = nil end
	end
	
	-- Return Table.
	return Table
end

-- Get Alpha From Distance.
function citrus.Utilities.GetAlphaFromDistance(First, Second, MaximumDistance)
	local Length = math.max((First:GetPos() - Second:GetPos()):Length(), 128)
	
	-- Return Clamp.
	return math.Clamp(255 - ((255 / MaximumDistance) * Length), 0, 255)
end

-- Get Color.
function citrus.Utilities.GetColor(String)
	local Exploded = citrus.Utilities.Explode(String, ",")
	
	-- For Loop.
	for K, V in pairs(Exploded) do Exploded[K] = string.Trim(V) end
	
	-- R.
	local R = tonumber(Exploded[1]) or 255
	local G = tonumber(Exploded[2]) or 255
	local B = tonumber(Exploded[3]) or 255
	local A = tonumber(Exploded[4]) or 255
	
	-- Return Color.
	return Color(R, G, B, A)
end

-- Get Random Value.
function citrus.Utilities.GetRandomValue(Table)
	local Temporary = {}
	
	-- For Loop.
	for K, V in pairs(Table) do Temporary[#Temporary + 1] = V end
	
	-- Maximum.
	local Maximum = math.random(1, table.getn(Temporary))	
	local Type = type(Temporary[Maximum])
	
	-- Check Type.
	if (Type == "table") then return citrus.Utilities.GetRandomValue(Temporary[Maximum]) end
	
	-- Return Maximum.
	return Temporary[Maximum]
end

-- Include Directory.
function citrus.Utilities.IncludeDirectory(Directory, Prefix, Extension, Recursive)
	local Files = file.FindInLua(Directory.."*"..Extension)
	
	-- For Loop.
	for K, V in pairs(Files) do
		if (V != "." and V != "..") then
			if (file.IsDir("../lua/"..Directory..V.."/") and Recursive) then
				citrus.Utilities.IncludeDirectory(Directory..V.."/", Prefix, Extension, Recursive)
			else
				if (!Prefix or string.sub(V, 1, string.len(Prefix)) == Prefix) then include(Directory..V) end
			end
		end
	end
end

-- File Append.
function citrus.Utilities.FileAppend(File, Text)
	local Contents = file.Read(File) or ""
	
	-- Contents.
	Contents = Contents..Text.."\n"
	
	-- Write.
	file.Write(File, Contents)
end

-- File Execute.
function citrus.Utilities.FileExecute(File)
	local File = file.Read("../"..File)
	
	-- Check File.
	if (File) then
		local Exploded = string.Explode("\n", File)
		
		-- For Loop.
		for K, V in pairs(Exploded) do game.ConsoleCommand(V.."\n") end
	end
end

-- Gamemode Derives From.
function citrus.Utilities.GamemodeDerivesFrom(Gamemode)
	local BaseClass = GAMEMODE
	
	-- While Loop.
	while BaseClass do
		if (string.lower(BaseClass.Name) == string.lower(Gamemode)) then return true end
		
		-- Base Class.
		BaseClass = BaseClass.BaseClass
	end
	
	-- Return False.
	return false
end

function citrus.Utilities.IsValidEnt(Entity)
	return (Entity.IsValid and Entity:IsValid())
end