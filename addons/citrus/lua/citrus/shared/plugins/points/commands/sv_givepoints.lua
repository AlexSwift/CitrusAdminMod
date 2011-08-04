--[[
Name: "sv_givepoints.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("givepoints", "A", {{"Player", "player"}, {"Point(s)", "number"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Points")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Give Points.
function COMMAND.GivePoints(Player, Points, Name)
	PLUGIN.Give(Player, Points)
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", Player:Name().." is given "..Points.." point(s) ("..Name..").")
	citrus.Player.NotifyByAccess("!M", Player:Name().." is given "..Points.." point(s).")
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	if (Arguments[2] <= 0) then print("Unable to give negative points!") return end
	
	-- Give Points.
	COMMAND.GivePoints(Arguments[1], Arguments[2], "Console")
	
	-- Print.
	print(Arguments[1]:Name().." is given "..Arguments[2].." point(s) (Console).")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	if (Arguments[2] <= 0) then citrus.Player.Notify(Player, "Unable to give negative points!", 1) return end
	
	-- Give Points.
	COMMAND.GivePoints(Arguments[1], Arguments[2], Player:Name())
end

-- Get Points.
function COMMAND.GetPoints(Player, Menu, Argument)
	Menu:SliderAdd("Point(s)", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 60)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Management", "Give Point(s)", {{"Player", citrus.QuickMenu.GetPlayer}, {"Point(s)", COMMAND.GetPoints}})

-- Create.
COMMAND:Create()