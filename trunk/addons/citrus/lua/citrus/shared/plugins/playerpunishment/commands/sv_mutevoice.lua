--[[
Name: "sv_mutevoice.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("mutevoice", "M", {{"Player", "player"}, {"Mute Voice", "boolean"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Punishment")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- MuteVoice.
function COMMAND.MuteVoice(Player, Boolean, Name)
	PLUGIN:UsermessageCall("Mute Voice", Player, function() umsg.Bool(Boolean) end)
	
	-- Check Boolean.
	if (Boolean) then
		citrus.Player.NotifyByAccess("M", Player:Name().."'s voice is muted  ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().."'s voice is muted .")
	else
		citrus.Player.NotifyByAccess("M", Player:Name().."'s voice is unmuted  ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().."'s voice is unmuted .")
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.MuteVoice(Arguments[1], Arguments[2], "Console")
	
	-- Check 2.
	if (Arguments[2]) then
		print(Arguments[1]:Name().."'s voice is muted (Console).")
	else
		print(Arguments[1]:Name().."'s voice is unmuted (Console).")
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Mute Voice.
	COMMAND.MuteVoice(Arguments[1], Arguments[2], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Punishment", "Mute Voice", {{"Player", citrus.QuickMenu.GetPlayer}, {"Mute Voice", citrus.QuickMenu.GetBoolean}})

-- Create.
COMMAND:Create()