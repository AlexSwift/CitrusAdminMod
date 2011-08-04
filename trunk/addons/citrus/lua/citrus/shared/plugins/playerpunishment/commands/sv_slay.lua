--[[
Name: "sv_slay.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("slay", "M", {{"Player", "player"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Punishment")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Slay.
function COMMAND.Slay(Player, Name)
	Player:Kill()
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", Player:Name().." is slayed ("..Name..").")
	citrus.Player.NotifyByAccess("!M", Player:Name().." is slayed.")
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Slay(Arguments[1], "Console")
	
	-- Print.
	print(Arguments[1]:Name().." is slayed (Console).")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Slay.
	COMMAND.Slay(Arguments[1], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Punishment", "Slay", {{"Player", citrus.QuickMenu.GetPlayer}})

-- Create.
COMMAND:Create()