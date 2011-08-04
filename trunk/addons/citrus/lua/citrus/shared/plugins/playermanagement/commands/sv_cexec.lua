--[[
Name: "sv_cexec.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("cexec", "A", {{"Player", "player"}, {"Command", "string"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Management")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	citrus.Player.ConsoleCommand(Arguments[1], Arguments[2])
	
	-- Print.
	print("Command '"..Arguments[2].."' is run on "..Arguments[1]:Name().." (Console).")
	
	-- Notify.
	citrus.Player.NotifyByAccess("M", "Command '"..Arguments[2].."' is run on "..Arguments[1]:Name().." (Console).")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Console Command.
	citrus.Player.ConsoleCommand(Arguments[1], Arguments[2])
	
	-- Notify.
	citrus.Player.NotifyByAccess("M", "Command '"..Arguments[2].."' is run on "..Arguments[1]:Name().." ("..Player:Name()..").")
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Management", "CEXEC", {{"Player", citrus.QuickMenu.GetPlayer}, {"Command", citrus.QuickMenu.GetText}})

-- Create.
COMMAND:Create()