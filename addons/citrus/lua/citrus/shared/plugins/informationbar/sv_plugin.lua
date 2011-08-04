--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Information Bar")

-- Game Support.
PLUGIN.Settings.GameSupport = false
PLUGIN.Settings.Description = "Players see a bar telling them how to see their information"
PLUGIN.Settings.Gamemode = {"Sandbox", false}
PLUGIN.Settings.Author = "Conna"

-- On Second.
function PLUGIN.OnSecond()
	citrus.NetworkVariables.Set("Information Bar", "Hostname", GetConVarString("hostname"))
end

-- On Player Initial Spawn.
function PLUGIN.OnPlayerInitialSpawn(Player)
	PLUGIN:UsermessageCall("Hostname", Player, function() umsg.String(GetConVarString("hostname")) end)
end

-- Show Spare 2.
function PLUGIN.ShowSpare2(Player)
	citrus.PlayerInformation.Show(Player, Player)
	
	-- Return False.
	return false
end

-- Hook Add.
PLUGIN:HookAdd("ShowSpare2", PLUGIN.ShowSpare2)
