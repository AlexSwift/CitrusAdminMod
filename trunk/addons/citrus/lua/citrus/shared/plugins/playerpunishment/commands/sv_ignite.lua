--[[
Name: "sv_ignite.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("ignite", "M", {{"Player", "player"}, {"Ignite", "boolean"}, {"Duration", "number", true}, {"Radius", "number", true}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Punishment")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Ignite.
function COMMAND.Ignite(Player, Boolean, Duration, Radius, Name)
	if (Boolean) then
		Player:Ignite(Duration or 60, Radius or 0)
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Player:Name().." is ignited for "..(Duration or 60).." second(s) ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is ignited for "..(Duration or 60).." second(s).")
	else
		Player:Extinguish()
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Player:Name().." is unignited ("..Name..").")
		citrus.Player.NotifyByAccess("!M", Player:Name().." is unignited.")
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Ignite(Arguments[1], Arguments[2], Arguments[3], Arguments[4], "Console")
	
	-- Check 2.
	if (Arguments[2]) then
		print(Arguments[1]:Name().." is ignited (Console).")
	else
		print(Arguments[1]:Name().." is unignited (Console).")
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Ignite.
	COMMAND.Ignite(Arguments[1], Arguments[2], Arguments[3], Arguments[4], Player:Name())
end

-- Get Duration.
function COMMAND.GetDuration(Player, Menu, Argument)
	Menu:SliderAdd("Duration", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 250)
end

-- Get Radius.
function COMMAND.GetRadius(Player, Menu, Argument)
	Menu:SliderAdd("Radius", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 250)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Punishment", "Ignite", {{"Player", citrus.QuickMenu.GetPlayer}, {"Ignite", citrus.QuickMenu.GetBoolean}, {"Duration", COMMAND.GetDuration}, {"Radius", COMMAND.GetRadius}})

-- Create.
COMMAND:Create()