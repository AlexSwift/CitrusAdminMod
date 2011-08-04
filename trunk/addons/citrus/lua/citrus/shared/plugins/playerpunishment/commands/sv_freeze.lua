--[[
Name: "sv_freeze.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("freeze", "M", {{"Player", "player"}, {"Freeze", "boolean"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Punishment")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Freeze.
function COMMAND.Freeze(Player, Boolean, Name)
	Player:Freeze(Boolean)
	
	-- Check Boolean.
	if (Boolean) then
		citrus.Player.NotifyByAccess("M", Player:Name().." is frozen ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is frozen.")
	else
		citrus.Player.NotifyByAccess("M", Player:Name().." is unfrozen ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is unfrozen.")
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Freeze(Arguments[1], Arguments[2], "Console")
	
	-- Check 2.
	if (Arguments[2]) then
		print(Arguments[1]:Name().." is frozen (Console).")
	else
		print(Arguments[1]:Name().." is unfrozen (Console).")
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Freeze.
	COMMAND.Freeze(Arguments[1], Arguments[2], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Punishment", "Freeze", {{"Player", citrus.QuickMenu.GetPlayer}, {"Freeze", citrus.QuickMenu.GetBoolean}})

-- Create.
COMMAND:Create()