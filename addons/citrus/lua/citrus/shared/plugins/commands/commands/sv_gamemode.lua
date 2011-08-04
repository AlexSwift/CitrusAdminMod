--[[
Name: "sv_gamemode.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("gamemode", "A", {{"Gamemode", "string"}, {"Map", "string", true}, {"Delay", "number", true}, {"Default", "boolean", true}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Gamemode.
function COMMAND.Gamemode(Gamemode, Map, Delay, Default, Name, Console)
	if (Default) then game.ConsoleCommand("sv_defaultgamemode "..Gamemode.."\n") end
	
	-- Delay.
	Delay = Delay or 1
	
	-- Simple.
	timer.Simple(Delay, game.ConsoleCommand, "changegamemode "..(Map or game.GetMap()).." "..Gamemode.."\n")
	
	-- Countdown Add.
	citrus.Player.CountdownAdd(nil, "Change Gamemode", "Change Gamemode", Delay)
	
	-- Delay.
	Delay = citrus.Utilities.GetFormattedTime(Delay, "%hh %mm %ss")
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", "Changing gamemode to "..Gamemode.." in "..Delay.." ("..Name..").", 0)
	citrus.Player.NotifyByAccess("!M", "Changing gamemode to "..Gamemode.." in "..Delay..".", 0)
	
	-- Check Console.
	if (Console) then
		print("Changing gamemode to "..Gamemode.." in "..Delay.." ("..Name..").")
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Gamemode(Arguments[1], Arguments[2], Arguments[3], Arguments[4], "Console", true)
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	COMMAND.Gamemode(Arguments[1], Arguments[2], Arguments[3], Arguments[4], Player:Name())
end

-- Get Map.
function COMMAND.GetMap(Player, Menu, Argument)
	local Maps = file.Find("../maps/*.bsp")
	
	-- For Loop.
	for K, V in pairs(Maps) do
		if (string.find(V, "^de_") or string.find(V, "^cs_") or string.find(V, "^es_")
		or string.find(V, "^cp_") or string.find(V, "^tc_") or string.find(V, "^ctf_")
		or string.find(V, "^gm_") or string.find(V, "^gmdm_") or string.find(V, "^rp_")
		or string.find(V, "^dod_")) then
			V = string.Replace(V, ".bsp", "")
			
			-- Button Add.
			Menu:ButtonAdd(V, function()
				citrus.QuickMenu.SetArgument(Player, Argument, V)
			end)
		end
	end
end

-- Get Gamemodes.
function COMMAND.GetGamemodes(Player, Menu, Argument)
	local Gamemodes = file.Find("../gamemodes/*")
	
	-- For Loop.
	for K, V in pairs(Gamemodes) do
		if (V != "." and V != "..") then
			Menu:ButtonAdd(V, function()
				citrus.QuickMenu.SetArgument(Player, Argument, V)
			end)
		end
	end
end

-- Get Delay.
function COMMAND.GetDelay(Player, Menu, Argument)
	Menu:SliderAdd("Delay", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 250)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Server Management", "Gamemode", {{"Gamemode", COMMAND.GetGamemodes}, {"Map", COMMAND.GetMap}, {"Delay", COMMAND.GetDelay}, {"Default", citrus.QuickMenu.GetBoolean}}, "gui/silkicons/plugin")

-- Create.
COMMAND:Create()