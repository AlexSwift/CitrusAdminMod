--[[
Name: "sv_send.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("send", "M", {{"Player", "player"}, {"Target", "player"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Management")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Send.
function COMMAND.Send(Player, Target, Name)
	local Position = Target:GetPos() + Target:GetAimVector() * -128
	
	-- Set Pos.
	Player:SetPos(Position)
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", Player:Name().." is sent to "..Target:Name().." ("..Name..").")
	citrus.Player.NotifyByAccess("!M", Player:Name().." is sent to "..Target:Name()..".")
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Send(Arguments[1], Arguments[2], "Console")
	
	-- Print.
	print(Arguments[1]:Name().." is sent to "..Arguments[2]:Name().." (Console).")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Send.
	COMMAND.Send(Arguments[1], Arguments[2], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Management", "Send", {{"Player", citrus.QuickMenu.GetPlayer}, {"Player", citrus.QuickMenu.GetPlayer}})

-- Create.
COMMAND:Create()