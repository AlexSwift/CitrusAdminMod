--[[
Name: "sv_maximise.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("maximise", false)

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Callback.
function COMMAND.Callback(Player, Arguments) Player:SendLua("citrus.Menus.SetMaximised()") end

-- Create.
COMMAND:Create()