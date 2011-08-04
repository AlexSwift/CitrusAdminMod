--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Advertisments")

-- Description.
PLUGIN.Settings.Description = "A random advertisment is displayed each minute"
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Advertisments"]

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/advertisments.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/advertisments.txt", PLUGIN.Configuration)
end

-- On Minute.
function PLUGIN.OnMinute()
	if (table.Count(PLUGIN.Configuration) != 0) then
		citrus.Player.NotifyAll(citrus.Utilities.GetRandomValue(PLUGIN.Configuration), 3)
	end
end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")