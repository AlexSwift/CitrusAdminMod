--[[
Name: "sv_blind.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("blind", "M", {{"Player", "player"}, {"Blind", "boolean"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Punishment")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Blind.
function COMMAND.Blind(Player, Boolean, Name)
	if (Boolean) then
		citrus.Player.OverlayAdd(Player, "Blind", "You are blind!", "Punished by "..Name, 255)
	else
		citrus.Player.OverlayRemove(Player, "Blind")
	end
	
	-- Check Boolean.
	if (Boolean) then
		citrus.Player.NotifyByAccess("M", Player:Name().." is blinded ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is blinded.")
	else
		citrus.Player.NotifyByAccess("M", Player:Name().." is unblinded ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is unblinded.")
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Blind(Arguments[1], Arguments[2], "Console")
	
	-- Check 2.
	if (Arguments[2]) then
		print(Arguments[1]:Name().." is blinded (Console).")
	else
		print(Arguments[1]:Name().." is unblinded (Console).")
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Blind.
	COMMAND.Blind(Arguments[1], Arguments[2], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Punishment", "Blind", {{"Player", citrus.QuickMenu.GetPlayer}, {"Blind", citrus.QuickMenu.GetBoolean}})

-- Create.
COMMAND:Create()