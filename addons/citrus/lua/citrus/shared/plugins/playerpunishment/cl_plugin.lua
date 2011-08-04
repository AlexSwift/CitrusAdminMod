--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Player Punishment")

-- Voice Muted.
PLUGIN.VoiceMuted = false

-- Usermessage Hook.
PLUGIN:UsermessageHook("Mute Voice", function(Message)
	PLUGIN.VoiceMuted = Message:ReadBool()
end)

-- Hook Add.
PLUGIN:HookAdd("PlayerBindPress", function(Player, Bind, Press)
	if (PLUGIN.VoiceMuted and string.find(Bind, "+voicerecord")) then return true end
end)