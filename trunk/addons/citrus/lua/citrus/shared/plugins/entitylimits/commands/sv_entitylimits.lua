--[[
Name: "sv_entitylimits.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("entitylimits", "S")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Entity Limits")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Entity Limits")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetReference(COMMAND.Callback)
	
	-- For Loop.
	for K, V in pairs(citrus.Groups.Stored) do
		Menu:ButtonAdd(V.Name, function() COMMAND.Group(Player, V) end)
	end
	
	-- Send.
	Menu:Send()
end

-- Set Limit.
function COMMAND.SetLimit(Player, Group, Type, Limit)
	PLUGIN.Configuration[Group.Name] = PLUGIN.Configuration[Group.Name] or {}
	PLUGIN.Configuration[Group.Name][Type] = Limit
end

-- Group.
function COMMAND.Group(Player, Group)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Entity Limits ("..Group.Name..")")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetUpdate(COMMAND.Group, Group)
	Menu:SetReference(COMMAND.Group, Group)
	
	-- Button Add.
	Menu:ButtonAdd("Default", function()
		PLUGIN.Configuration[Group.Name] = nil
		
		-- Update.
		citrus.Menus.Update(nil, COMMAND.Group, Group)
		
		-- Notify All.
		citrus.Player.NotifyAll("Entity limits for "..Group.Name.." set to default.")
	end)
	
	-- Text Add.
	Menu:TextAdd("Setting the limit to -1 will allow players in this group")
	Menu:TextAdd("to spawn unlimited amounts of that type of entity.")
	
	-- Table.
	local Table = {
		"Props",
		"Ragdolls",
		"Vehicles",
		"Effects",
		"Balloons",
		"NPCs",
		"SENTs",
		"Dynamite",
		"Lamps",
		"Wheels",
		"Thrusters",
		"Hoverballs",
		"Buttons",
		"Emitters",
		"Spawners",
		"Turrets"
	}
	
	-- For Loop.
	for K, V in pairs(Table) do
		local Value = GetConVarNumber("sbox_max"..string.lower(V))
		
		-- Check Name.
		if (PLUGIN.Configuration[Group.Name] and PLUGIN.Configuration[Group.Name][string.lower(V)]) then
			Value = PLUGIN.Configuration[Group.Name][string.lower(V)] or 0
		end
		
		-- Slider Add.
		Menu:SliderAdd(V, function(Player, Value)
			COMMAND.SetLimit(Player, Group, string.lower(V), Value)
			
			-- Notify All.
			citrus.Player.NotifyAll(V.." limit for "..Group.Name.." set to "..Value..".")	
		end, 0, 250, {Value = Value})
	end
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Entity Limits")

-- Create.
COMMAND:Create()