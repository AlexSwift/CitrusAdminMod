--[[
Name: "sv_lua.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("lua", "S", {{"Command", "string"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	RunString(Arguments[1])
	
	-- Print.
	print("Lua '"..Arguments[1].."' is run (Console).")
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", "Lua '"..Arguments[1].."' is run (Console).")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	RunString(Arguments[1])
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", "Lua '"..Arguments[1].."' is run ("..Player:Name()..").")
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Server Management", "Lua", {{"Command", citrus.QuickMenu.GetText}}, "gui/silkicons/application")

-- Create.
COMMAND:Create()