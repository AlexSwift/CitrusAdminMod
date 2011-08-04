--[[
Name: "sv_bring.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("bring", "M", {{"Player", "player"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Management")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Position.
	local Position = Player:GetPos() + Player:GetAimVector() * -128
	
	-- Set Pos.
	Arguments[1]:SetPos(Position)
	
	-- Notify All.
	citrus.Player.NotifyAll(Arguments[1]:Name().." is brought to "..Player:Name()..".")
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Management", "Bring", {{"Player", citrus.QuickMenu.GetPlayer}})

-- Create.
COMMAND:Create()