--[[
Name: "sv_ban.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("ban", "A", {{"Player", "player"}, {"Duration", "number"}, {"Reason", "string", true, "N/A"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Ban.
function COMMAND.Ban(Player, Duration, Reason, Name, Console)
	citrus.Bans.Add(Player, Name, Duration * 60, Reason, true)
	
	-- Check Duration.
	if (Duration == 0) then
		citrus.Player.NotifyByAccess("M", Player:Name().." is banned permanantly ("..Name..").", 0)
		citrus.Player.NotifyByAccess("!M", Player:Name().." is banned permanantly.", 0)
		
		-- Check Console.
		if (Console) then print(Player:Name().." is banned permanantly ("..Name..").") end
	else
		Duration = citrus.Utilities.GetFormattedTime(Duration * 60, "%hh %mm %ss")
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Player:Name().." is banned for "..Duration.." ("..Name..").", 0)
		citrus.Player.NotifyByAccess("!M", Player:Name().." is banned for "..Duration..".", 0)
		
		-- Check Console.
		if (Console) then print(Player:Name().." is banned for "..Duration.." ("..Name..").") end
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Ban(Arguments[1], Arguments[2], Arguments[3], "Console", true)
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Error = citrus.Player.IsImmune(Player, Arguments[1])
	
	-- Check Error.
	if (Error and Player != Arguments[1]) then citrus.Player.Notify(Player, Error, 1) return end
	
	-- Ban.
	COMMAND.Ban(Arguments[1], Arguments[2], Arguments[3], Player:Name())
end

-- Get Duration.
function COMMAND.GetDuration(Player, Menu, Argument)
	Menu:SliderAdd("Duration", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 250)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Administration", "Ban", {{"Player", citrus.QuickMenu.GetPlayer}, {"Duration", COMMAND.GetDuration}, {"Reason", citrus.QuickMenu.GetText}}, "gui/silkicons/exclamation")

-- Create.
COMMAND:Create()