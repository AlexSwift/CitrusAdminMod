--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Rules")

-- Description.
PLUGIN.Settings.Description = "Can display a set rules to players when they connect"
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Rules"]

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/rules.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/rules.txt", PLUGIN.Configuration)
end

-- On Player Initial Spawn.
function PLUGIN.OnPlayerInitialSpawn(Player)
	if (!citrus.Access.Has(Player, "M")) then
		local Menu = citrus.Menu:New()
		
		-- Set Player.
		Menu:SetPlayer(Player)
		Menu:SetTitle("Rules")
		Menu:SetIcon("gui/silkicons/exclamation")
		Menu:SetReference(PLUGIN.OnPlayerInitialSpawn)
		
		-- Rule.
		local Rule = 1
		
		-- For Loop.
		for K, V in pairs(PLUGIN.Configuration) do
			Menu:TextAdd(Rule..". "..V)
			
			-- Rule.
			Rule = Rule + 1
		end
		
		-- Check Count.
		if (table.Count(PLUGIN.Configuration) == 0) then
			Menu:TextAdd("Unable to locate rules!")
		end
		
		-- Send.
		Menu:Send()
	end
end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")