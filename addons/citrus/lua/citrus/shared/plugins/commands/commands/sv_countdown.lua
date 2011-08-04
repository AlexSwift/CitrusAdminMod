--[[
Name: "sv_countdown.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("countdown", "M", {{"Title", "string"}, {"Duration", "number"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Countdown.
function COMMAND.Countdown(Title, Duration, Name, Console)
	citrus.Player.CountdownAdd(nil, Title, Title, Duration)
	
	-- Check 2.
	if (Duration == 0) then
		if (Console) then print("Countdown '"..Arguments[1].."' is removed ("..Name..").") end
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", "Countdown '"..Title.."' is removed ("..Name..").", 0)
		citrus.Player.NotifyByAccess("!M", "Countdown '"..Title.."' is removed.", 0)
	else
		if (Console) then print("Countdown '"..Arguments[1].."' is added ("..Name..").") end
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", "Countdown '"..Title.."' is added ("..Name..").", 0)
		citrus.Player.NotifyByAccess("!M", "Countdown '"..Title.."' is added.", 0)
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	if (string.len(Arguments[1]) > 32) then
		print("Unable to use title with greater than 32 characters!")
		
		-- Return.
		return
	end
	
	-- Countdown.
	COMMAND.Countdown(Arguments[1], Arguments[2], "Console", true)
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	if (string.len(Arguments[1]) > 32) then
		citrus.Player.Notify(Player, "Unable to use title with greater than 32 characters!", 1)
		
		-- Return.
		return
	end
	
	-- Countdown.
	COMMAND.Countdown(Arguments[1], Arguments[2], Player:Name())
end

-- Get Duration.
function COMMAND.GetDuration(Player, Menu, Argument)
	Menu:SliderAdd("Duration", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 250)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Server Management", "Countdown", {{"Title", citrus.QuickMenu.GetText}, {"Duration", COMMAND.GetDuration}}, "gui/silkicons/application")

-- Create.
COMMAND:Create()