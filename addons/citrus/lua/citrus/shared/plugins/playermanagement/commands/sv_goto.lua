--[[
Name: "sv_goto.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("goto", "B", {{"Player", "player"}})

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
	local Position = Arguments[1]:GetPos() + Arguments[1]:GetAimVector() * -128
	
	-- Set Pos.
	Player:SetPos(Position)
	
	-- Notify All.
	citrus.Player.NotifyAll(Player:Name().." has gone to "..Arguments[1]:Name()..".")
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Standalone Commands", "Go To", {{"Player", citrus.QuickMenu.GetPlayer}})

-- Create.
COMMAND:Create()