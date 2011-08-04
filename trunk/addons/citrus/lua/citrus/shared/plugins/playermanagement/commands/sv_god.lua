--[[
Name: "sv_god.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("god", "A", {{"Player", "player"}, {"God", "boolean"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Management")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- God.
function COMMAND.God(Player, Boolean, Name)
	if (Boolean) then
		Player:GodEnable()
	else
		Player:GodDisable()
	end
	
	-- Check Boolean.
	if (Boolean) then
		citrus.Player.NotifyByAccess("M", Player:Name().." is godded ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is godded.")
	else
		citrus.Player.NotifyByAccess("M", Player:Name().." is ungodded ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is ungodded.")
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.God(Arguments[1], Arguments[2], "Console")
	
	-- Check 2.
	if (Arguments[2]) then
		print(Arguments[1]:Name().." is godded (Console).")
	else
		print(Arguments[1]:Name().." is ungodded (Console).")
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	COMMAND.God(Arguments[1], Arguments[2], Player:Name())
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Management", "God", {{"Player", citrus.QuickMenu.GetPlayer}, {"God", citrus.QuickMenu.GetBoolean}})

-- Create.
COMMAND:Create()