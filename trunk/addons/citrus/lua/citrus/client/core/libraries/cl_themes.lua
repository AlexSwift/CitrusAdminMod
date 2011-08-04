--[[
Name: "cl_themes.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Themes = {}
citrus.Themes.ClientSide = "Citrus"
citrus.Themes.ServerSide = "Citrus"

-- Create Client ConVar.
CreateClientConVar("cl_citrus_theme", "", true, true)

-- NEW_THEME.
local NEW_THEME = false

-- On Think.
function citrus.Themes.OnThink()
	if (citrus.Themes.Stored[GetConVarString("cl_citrus_theme")]) then
		citrus.Themes.ClientSide = GetConVarString("cl_citrus_theme")
	else
		citrus.Themes.ClientSide = citrus.Themes.ServerSide
	end
end

-- Add.
citrus.Hooks.Add("OnThink", citrus.Themes.OnThink)

-- Initialize.
function citrus.Themes.Initialize()
	citrus.Themes.Stored = {}
	
	-- Themes.
	local Themes = file.Find("citrus/themes/*.txt")
	
	-- For Loop.
	for K, V in pairs(Themes) do
		local Parse = citrus.ParseINI:New("data/citrus/themes/"..V)
		
		-- Results
		local Results = Parse:Parse()
		local Table = {}
		
		-- Name.
		Table.Name = Results.Settings.Name
		
		-- Settings.
		Table.Settings = Results.Settings
		Table.Settings.Name = nil
		
		-- Colors.
		Table.Colors = {}
		Table.Sizes = Results.Sizes
		
		-- For Loop.
		for K2, V2 in pairs(Results.Colors) do
			Table.Colors[K2] = citrus.Utilities.GetColor(V2)
		end
		
		-- Name.
		citrus.Themes.Stored[Table.Name] = Table
	end
end

-- Add.
hook.Add("Initialize", "citrus.Themes.Initialize", citrus.Themes.Initialize)

-- Save.
function citrus.Themes.Save(Theme)
	local String = "[Settings]\n"
	
	-- String.
	String = String.."Name = "..Theme.Name.."\n"
	
	-- For Loop.
	for K, V in pairs(Theme.Settings) do
		String = String..K.." = "..V.."\n"
	end
	
	-- String.
	String = String.."[Colors]\n"
	
	-- For Loop.
	for K, V in pairs(Theme.Colors) do
		String = String..K.." = "..V.r..", "..V.g..", "..V.b..", "..V.a.."\n"
	end
	
	-- String.
	String = String.."[Sizes]\n"
	
	-- For Loop.
	for K, V in pairs(Theme.Sizes) do
		String = String..K.." = "..V.."\n"
	end
	
	-- String.
	String = string.sub(String, 1, -2)
	
	-- Write.
	file.Write("citrus/themes/cl_"..Theme.Name..".txt", String)
end

-- Set.
function citrus.Themes.Set(Theme)
	if (citrus.Themes.Stored[Theme]) then
		citrus.Themes.ClientSide = Theme
	end
end

-- Get Color.
function citrus.Themes.GetColor(Name)
	if (citrus.Themes.Stored[citrus.Themes.ClientSide]) then
		if (citrus.Themes.Stored[citrus.Themes.ClientSide].Colors[Name]) then
			return table.Copy(citrus.Themes.Stored[citrus.Themes.ClientSide].Colors[Name])
		end
	end
	
	-- Return Color.
	return Color(0, 0, 0, 0)
end

-- Get Size.
function citrus.Themes.GetSize(Name)
	if (citrus.Themes.Stored[citrus.Themes.ClientSide]) then
		if (citrus.Themes.Stored[citrus.Themes.ClientSide].Sizes[Name]) then
			return citrus.Themes.Stored[citrus.Themes.ClientSide].Sizes[Name]
		end
	end
	
	-- Return 0.
	return 0
end

-- Hook.
usermessage.Hook("citrus.Themes.Set", function(Message)
	local Theme = Message:ReadString()
	
	-- Server.
	citrus.Themes.ServerSide = Theme
	
	-- Check Get ConVar String.
	if (!citrus.Themes.Stored[GetConVarString("cl_citrus_theme")]) then
		citrus.Themes.Set(Theme)
	end
end)

-- Hook.
usermessage.Hook("citrus.Themes.New", function(Message)
	NEW_THEME = {Name = Message:ReadString(), Settings = {}, Colors = {}, Sizes = {}}
end)

-- Hook.
usermessage.Hook("citrus.Themes.Setting", function(Message)
	local Key = Message:ReadString()
	local Value = Message:ReadString()
	
	-- Key.
	NEW_THEME.Settings[Key] = Value
end)

-- Hook.
usermessage.Hook("citrus.Themes.Color", function(Message)
	local Key = Message:ReadString()
	local R = Message:ReadShort()
	local G = Message:ReadShort()
	local B = Message:ReadShort()
	local A = Message:ReadShort()
	
	-- Key.
	NEW_THEME.Colors[Key] = Color(R, G, B, A)
end)

-- Hook.
usermessage.Hook("citrus.Themes.Size", function(Message)
	local Key = Message:ReadString()
	local Value = Message:ReadShort()
	
	-- Key.
	NEW_THEME.Sizes[Key] = Value
end)

-- Add.
usermessage.Hook("citrus.Themes.Add", function(Message)
	citrus.Themes.Stored[NEW_THEME.Name] = NEW_THEME
	
	-- Save.
	citrus.Themes.Save(citrus.Themes.Stored[NEW_THEME.Name])
end)