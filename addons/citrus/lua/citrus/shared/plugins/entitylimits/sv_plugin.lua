--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Entity Limits")

-- Description.
PLUGIN.Settings.Description = "Configured groups can have different limits for entities"
PLUGIN.Settings.Gamemode = {"Sandbox", true}
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()

-- Check Limit.
local CheckLimit = _R["Player"].CheckLimit

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/entitylimits.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)

	-- Check Limit.
	_R["Player"].CheckLimit = PLUGIN.CheckLimit
end

-- On Unload.
function PLUGIN:OnUnload()
	_R["Player"].CheckLimit = CheckLimit
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/entitylimits.txt", PLUGIN.Configuration)
end

-- Check Limit.
function PLUGIN.CheckLimit(Player, Type, Boolean)
	local Group = citrus.Player.GetGroup(Player)
	
	-- Check Group.
	if (PLUGIN.Configuration[Group.Name]) then
		if (PLUGIN.Configuration[Group.Name][Type]) then
			local Amount = PLUGIN.Configuration[Group.Name][Type]
			
			-- Check Get Count.
			if (Player:GetCount(Type) < Amount or Amount == -1) then
				return true
			else
				local Message = Group.Name.." are limited to spawning "..Amount.." "..Type.."!"
				
				-- Check Amount.
				if (Amount == 0) then
					Message = Group.Name.." are restricted from spawning "..Type.."!"
				end
				
				-- Notify.
				citrus.Player.Notify(Player, Message, 1)
				
				-- Return False.
				return false
			end
		end
	end
	
	-- Check Boolean.
	if (Boolean) then
		return
	else
		return CheckLimit(Player, Type)
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerSpawnRagdoll", function(Player)
	return PLUGIN.CheckLimit(Player, "ragdolls", true)
end)
PLUGIN:HookAdd("PlayerSpawnProp", function(Player)
	return PLUGIN.CheckLimit(Player, "props", true)
end)
PLUGIN:HookAdd("PlayerSpawnEffect", function(Player)
	return PLUGIN.CheckLimit(Player, "effects", true)
end)
PLUGIN:HookAdd("PlayerSpawnVehicle", function(Player)
	return PLUGIN.CheckLimit(Player, "vehicles", true)
end)
PLUGIN:HookAdd("PlayerSpawnSENT", function(Player)
	return PLUGIN.CheckLimit(Player, "sents", true)
end)
PLUGIN:HookAdd("PlayerSpawnNPC", function(Player)
	return PLUGIN.CheckLimit(Player, "npcs", true)
end)

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")