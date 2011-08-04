--[[
Name: "sv_rcon.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("rcon", "S", {{"Command", "string"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	citrus.Utilities.ConsoleCommand(Arguments[1])
	
	-- Print.
	print("RCon '"..Arguments[1].."' is run (Console).")
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", "RCon '"..Arguments[1].."' is run (Console).")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	citrus.Utilities.ConsoleCommand(Arguments[1])
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", "RCon '"..Arguments[1].."' is run ("..Player:Name()..").")
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Server Management", "RCon", {{"Command", citrus.QuickMenu.GetText}}, "gui/silkicons/application")

-- Create.
COMMAND:Create()