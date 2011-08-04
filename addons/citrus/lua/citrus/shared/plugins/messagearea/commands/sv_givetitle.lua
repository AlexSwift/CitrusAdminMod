--[[
Name: "sv_givetitle.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("givetitle", "A", {{"Player", "player"}, {"Title", "string"}, {"Red", "number", true, 255}, {"Green", "number", true, 255}, {"Blue", "number", true, 255}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Message Area")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Give Title.
function COMMAND.GiveTitle(Player, Title, R, G, B, Name)
	local MessageArea = citrus.PlayerVariables.Get(Player, "Message Area")
	
	-- Title.
	MessageArea.Title = "("..Title..")"
	MessageArea.Color = Color(R, G, B, 255)
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", Player:Name().." is given title '"..Title.."' ("..Name..").")
	citrus.Player.NotifyByAccess("!M", Player:Name().." is given title '"..Title.."'.")
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.GiveTitle(Arguments[1], Arguments[2], Arguments[3], Arguments[4], Arguments[5], "Console")
	
	-- Print.
	print(Arguments[1]:Name().." is given title '"..Arguments[2].."' (Console).")
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	COMMAND.GiveTitle(Arguments[1], Arguments[2], Arguments[3], Arguments[4], Arguments[5], Player:Name())
end

-- Get Red.
function COMMAND.GetRed(Player, Menu, Argument)
	Menu:SliderAdd("Red", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 255)
end

-- Get Green.
function COMMAND.GetGreen(Player, Menu, Argument)
	Menu:SliderAdd("Green", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 255)
end

-- Get Blue.
function COMMAND.GetBlue(Player, Menu, Argument)
	Menu:SliderAdd("Blue", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 255)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Management", "Give Title", {{"Player", citrus.QuickMenu.GetPlayer}, {"Title", citrus.QuickMenu.GetText}, {"Red", COMMAND.GetRed}, {"Green", COMMAND.GetGreen}, {"Blue", COMMAND.GetBlue}})

-- Create.
COMMAND:Create()