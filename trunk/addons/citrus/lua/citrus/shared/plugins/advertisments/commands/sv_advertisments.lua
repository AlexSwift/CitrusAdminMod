--[[
Name: "sv_advertisments.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("advertisments", "S")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Advertisments")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Add.
function COMMAND.Add(Player)
	citrus.Menus.TextEntry(Player, "Add Advertisment", function(Player, Text)
		PLUGIN.Configuration[#PLUGIN.Configuration + 1] = Text
		
		-- Update.
		citrus.Menus.Update(nil, COMMAND.Callback)
		citrus.Menus.Update(nil, COMMAND.Remove)
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", "Advertisment '"..Text.."' is added ("..Player:Name()..").")
		citrus.Player.NotifyByAccess("!M", "Advertisment '"..Text.."' is added.")
	end, true)
end

-- Remove.
function COMMAND.Remove(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Remove Advertisment")
	Menu:SetIcon("gui/silkicons/exclamation")
	Menu:SetUpdate(COMMAND.Remove)
	Menu:SetReference(COMMAND.Remove)
	
	-- For Loop.
	for K, V in pairs(PLUGIN.Configuration) do
		Menu:ButtonAdd(V, function()
			PLUGIN.Configuration[K] = nil
			
			-- Update.
			citrus.Menus.Update(nil, COMMAND.Callback)
			citrus.Menus.Update(nil, COMMAND.Remove)
			
			-- Notify By Access.
			citrus.Player.NotifyByAccess("M", "Advertisment '"..V.."' is removed ("..Player:Name()..").")
			citrus.Player.NotifyByAccess("!M", "Advertisment '"..V.."' is removed.")
		end)
	end
	
	-- Send.
	Menu:Send()
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Advertisments")
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
COMMAND:QuickMenuAdd("Plugin Configuration", "Advertisments")

-- Create.
COMMAND:Create()