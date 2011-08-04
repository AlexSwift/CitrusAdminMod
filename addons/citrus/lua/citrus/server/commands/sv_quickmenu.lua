--[[
Name: "sv_quickmenu.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("quickmenu")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Callback.
function COMMAND.Callback(Player, Arguments) citrus.QuickMenu.Display(Player) end	

-- Create.
COMMAND:Create()