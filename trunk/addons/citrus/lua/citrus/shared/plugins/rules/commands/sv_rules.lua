--[[
Name: "sv_rules.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("rules", "S")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Rules")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Add.
function COMMAND.Add(Player)
	citrus.Menus.TextEntry(Player, "Rule (Add)", function(Player, Text)
		PLUGIN.Configuration[#PLUGIN.Configuration + 1] = Text
		
		-- Update.
		citrus.Menus.Update(nil, COMMAND.Callback)
		citrus.Menus.Update(nil, COMMAND.Remove)
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", "Rule '"..Text.."' is added ("..Player:Name()..").")
		citrus.Player.NotifyByAccess("!M", "Rule '"..Text.."' is added.")
	end, true)
end

-- Remove.
function COMMAND.Remove(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Remove Rule")
	Menu:SetIcon("gui/silkicons/exclamation")
	Menu:SetUpdate(COMMAND.Remove)
	Menu:SetReference(COMMAND.Remove)
	
	-- For Loop.
	for K, V in pairs(PLUGIN.Configuration) do
		Menu:ButtonAdd(V, function()
			PLUGIN.Configuration[K] = nil
			
			-- Update.
			citrus.Menus.Update(nil, COMMAND.Callback)
			
			-- Notify By Access.
			citrus.Player.NotifyByAccess("M", "Rule '"..V.."' is removed ("..Player:Name()..").")
			citrus.Player.NotifyByAccess("!M", "Rule '"..V.."' is removed.")
		end, {Discontinue = true})
	end
	
	-- Send.
	Menu:Send()
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Rules")
	Menu:SetIcon("gui/silkicons/application")
	Menu:SetUpdate(COMMAND.Callback)
	Menu:SetReference(COMMAND.Callback)
	
	-- Button Add.
	Menu:ButtonAdd("Add", function() COMMAND.Add(Player) end)
	
	-- Check Count.
	if (table.Count(PLUGIN.Configuration) > 0) then
		Menu:ButtonAdd("Remove", function() COMMAND.Remove(Player) end)
	end
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Rules")

-- Create.
COMMAND:Create()