--[[
Name: "sv_kick.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("kick", "M", {{"Player", "player"}, {"Reason", "string", true, "N/A"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Kick.
function COMMAND.Kick(Player, Reason, Name, Console)
	citrus.Player.Kick(Player, Reason)
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", Player:Name().." is kicked ("..Name..").")
	citrus.Player.NotifyByAccess("!M", Player:Name().." is kicked.")
	
	-- Check Console.
	if (Console) then print(Player:Name().." is kicked ("..Name..").") end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Kick(Arguments[1], Arguments[2], "Console", true)
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Kick.
	COMMAND.Kick(Arguments[1], Arguments[2], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Administration", "Kick", {{"Player", citrus.QuickMenu.GetPlayer}, {"Reason", citrus.QuickMenu.GetText}}, "vgui/notices/error")

-- Create.
COMMAND:Create()