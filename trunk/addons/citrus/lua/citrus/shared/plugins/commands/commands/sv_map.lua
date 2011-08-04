--[[
Name: "sv_map.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("map", "A", {{"Map", "string"}, {"Delay", "number", true}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Map.
function COMMAND.Map(Map, Delay, Name, Console)		
	timer.Create(tostring(COMMAND.Map), Delay or 1, 1, game.ConsoleCommand, "changelevel "..Map.."\n")
	
	-- Countdown Add.
	citrus.Player.CountdownAdd(nil, "Change Map", "Change Map", Delay or 1)
	
	-- Delay.
	Delay = Delay or 1
	
	-- Delay.
	Delay = citrus.Utilities.GetFormattedTime(Delay, "%hh %mm %ss")
	
	-- Notify By Access.
	citrus.Player.NotifyByAccess("M", "Changing map to "..Map.." in "..Delay.." ("..Name..").", 0)
	citrus.Player.NotifyByAccess("!M", "Changing map to "..Map.." in "..Delay..".", 0)
	
	-- Check Console.
	if (Console) then
		print("Changing map to "..Map.." in "..Delay.." ("..Name..").")
	end
end

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	COMMAND.Map(Arguments[1], Arguments[2], "Console", true)
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	COMMAND.Map(Arguments[1], Arguments[2], Player:Name())
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

-- Get Delay.
function COMMAND.GetDelay(Player, Menu, Argument)
	Menu:SliderAdd("Delay", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 250)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Server Management", "Map", {{"Map", COMMAND.GetMap}, {"Delay", COMMAND.GetDelay}}, "gui/silkicons/world")

-- Create.
COMMAND:Create()