--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Restrict NoClip")

-- Description.
PLUGIN.Settings.Description = "NoClip can be restricted from use"
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Restrict NoClip"]

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/restrictnoclip.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/restrictnoclip.txt", PLUGIN.Configuration)
end

-- Player NoClip.
function PLUGIN.PlayerNoClip(Player)
	if (!citrus.Access.Has(Player, PLUGIN.Configuration["Access"])) then
		citrus.Player.Notify(Player, citrus.Access.GetName(PLUGIN.Configuration["Access"], "or").." access required!", 1)
		
		-- Return False.
		return false
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerNoClip", PLUGIN.PlayerNoClip)

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")