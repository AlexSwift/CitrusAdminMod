--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Reports")

-- Include.
include("sv_mysql.lua")

-- Description.
PLUGIN.Settings.Description = "Reports can be written and saved via MySQL"
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Reports"]

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

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")