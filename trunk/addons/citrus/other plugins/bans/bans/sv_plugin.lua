--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Bans")

-- Include.
include("sv_mysql.lua")

-- Description.
PLUGIN.Settings.Description = "Bans are saved via MySQL"
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Bans"]

-- On Load.
function PLUGIN:OnLoad()
	if (!gdatabase) then
		self:Unload(true)
	else
		local Success = PLUGIN.MySQL.Connect()
		
		-- Check Success.
		if (!Success) then self:Unload(true) end
	end
end

-- On Unload.
function PLUGIN:OnUnload() PLUGIN.MySQL.Disconnect() end

-- On Player Banned.
function PLUGIN.OnPlayerBanned(Player, Ban)
	PLUGIN.MySQL.Query("DELETE FROM "..PLUGIN.Configuration["Table"].." WHERE _SteamID = '"..Ban.SteamID.."'")
	
	-- Ban.
	Ban = table.Copy(Ban)
	Ban.Status = "Active"
	
	-- Insert.
	PLUGIN.MySQL.Insert(Ban)
end

-- On Player Unbanned.
function PLUGIN.OnPlayerUnbanned(Ban)
	PLUGIN.MySQL.Query("UPDATE "..PLUGIN.Configuration["Table"].." SET _Status = 'Lifted' WHERE _SteamID = '"..Ban.SteamID.."'")
end