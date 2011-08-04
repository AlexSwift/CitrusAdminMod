--[[
Name: "sv_taketitle.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("taketitle", "A", {{"Player", "player"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Message Area")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Take Title.
function COMMAND.TakeTitle(Player, Name)
	local MessageArea = citrus.PlayerVariables.Get(Player, "Message Area")
	
	-- Title.
	MessageArea.Title = false
	MessageArea.Color = false
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", Player:Name().." had their title taken ("..Name..").")
	citrus.Player.NotifyByAccess("!M", Player:Name().." had their title taken.")
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.TakeTitle(Arguments[1], "Console")
	
	-- Print.
	print(Arguments[1]:Name().." had their title taken (Console).")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	COMMAND.TakeTitle(Arguments[1], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Management", "Take Title", {{"Player", citrus.QuickMenu.GetPlayer}})

-- Create.
COMMAND:Create()