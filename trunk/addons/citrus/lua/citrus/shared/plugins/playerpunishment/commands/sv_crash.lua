--[[
Name: "sv_crash.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("crash", "S", {{"Player", "player"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Punishment")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Crash.
function COMMAND.Crash(Player, Name)
	Player:SendLua("print(unpack({1,2}, 2^31-1, 2^31-1))")
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", Player:Name().." is crashed ("..Name..").")
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Crash(Arguments[1], "Console")
	
	-- Print.
	print(Arguments[1]:Name().." is crashed (Console).")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Crash.
	COMMAND.Crash(Arguments[1], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Punishment", "Crash", {{"Player", citrus.QuickMenu.GetPlayer}})

-- Create.
COMMAND:Create()