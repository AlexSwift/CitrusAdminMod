--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Restrict SENTs")

-- Description.
PLUGIN.Settings.Description = "SENTs can be restricted from use"
PLUGIN.Settings.Gamemode = {"Sandbox", true}
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Restrict SENTs"]

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/restrictsents.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/restrictsents.txt", PLUGIN.Configuration)
end

-- Player Spawn SENT.
function PLUGIN.PlayerSpawnSENT(Player, SENT)
	SENT = scripted_ents.GetStored(SENT)
	
	-- Check SENT.
	if (SENT) then
		if (!SENT.Spawnable and !citrus.Access.Has(Player, PLUGIN.Configuration["Administrator Access"])) then
			citrus.Player.Notify(Player, citrus.Access.GetName(PLUGIN.Configuration["Administrator Access"], "or").." access required!", 1)
			
			-- Return False.
			return false
		else
			if (!citrus.Access.Has(Player, PLUGIN.Configuration["Access"])) then
				citrus.Player.Notify(Player, citrus.Access.GetName(PLUGIN.Configuration["Access"], "or").." access required!", 1)
				
				-- Return False.
				return false
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerSpawnSENT", PLUGIN.PlayerSpawnSENT)

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")