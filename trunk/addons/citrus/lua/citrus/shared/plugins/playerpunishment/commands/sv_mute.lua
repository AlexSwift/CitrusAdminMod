--[[
Name: "sv_mute.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("mute", "M", {{"Player", "player"}, {"Mute", "boolean"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Punishment")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Mute.
function COMMAND.Mute(Player, Boolean, Name)
	citrus.PlayerEvents.Allow(Player, "Mute", citrus.PlayerEvent.Say, !Boolean)
	
	-- Check Boolean.
	if (Boolean) then
		citrus.Player.NotifyByAccess("M", Player:Name().." is muted ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is muted.")
	else
		citrus.Player.NotifyByAccess("M", Player:Name().." is unmuted ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is unmuted.")
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Mute(Arguments[1], Arguments[2], "Console")
	
	-- Check 2.
	if (Arguments[2]) then
		print(Arguments[1]:Name().." is muted (Console).")
	else
		print(Arguments[1]:Name().." is unmuted (Console).")
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Mute.
	COMMAND.Mute(Arguments[1], Arguments[2], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Punishment", "Mute", {{"Player", citrus.QuickMenu.GetPlayer}, {"Mute", citrus.QuickMenu.GetBoolean}})

-- Create.
COMMAND:Create()