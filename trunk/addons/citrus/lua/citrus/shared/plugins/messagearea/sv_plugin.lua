--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Message Area")

-- Game Support.
PLUGIN.Settings.Description = "A message area with support for emoticons and tags"
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = {}

-- Emoticons.
local Emoticons = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Emoticons"]

-- For Loop.
for K, V in pairs(Emoticons) do
	local Key = string.sub(K, 2)
	
	-- Key.
	PLUGIN.Configuration[Key] = V
end

-- On Player Initial Spawn.
function PLUGIN:OnPlayerInitialSpawn(Player)
	for K, V in pairs(PLUGIN.Configuration) do
		PLUGIN:UsermessageCall("Emoticon", Player, function()
			umsg.String(K)
			umsg.String(V)
		end)
	end
end

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	citrus.PlayerVariables.New(Player, "Message Area", {})
end

-- Player Say.
function PLUGIN.PlayerSay(Player, Text, Public)
	if (!Public) then
		local Index = Player:Team()
		local Players = team.GetPlayers(Index)
		
		-- For Loop.
		for K, V in pairs(Players) do
			PLUGIN:UsermessageCall("Team Message", V, function()
				umsg.Entity(Player)
				umsg.String(Text)
			end)
		end
		
		-- Call.
		citrus.Hooks.Call("OnPlayerSay", Player, Text, Public)
		
		-- Return String.
		return ""
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerSay", PLUGIN.PlayerSay)

-- On Player Second.
function PLUGIN.OnPlayerSecond(Player)
	local MessageArea = citrus.PlayerVariables.Get(Player, "Message Area")
	
	-- Set.
	citrus.PlayerInformation.Set(Player, "Message Area", "Title", MessageArea.Title)
	
	-- Check Color.
	if (MessageArea.Color) then
		local Color = MessageArea.Color.r..", "..MessageArea.Color.g..", "..MessageArea.Color.b..", 255"
		
		-- Set.
		citrus.PlayerInformation.Set(Player, "Message Area", "Color", Color)
	else
		citrus.PlayerInformation.Set(Player, "Message Area", "Color", nil)
	end
end

-- For Loop.
for K, V in pairs(PLUGIN.Configuration) do
	resource.AddFile("materials/"..V..".vtf")
	resource.AddFile("materials/"..V..".vmt")
end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")