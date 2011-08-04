--[[
Name: "sv_donatepoints.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("donatepoints", "A", {{"Player", "player"}, {"Point(s)", "number"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Points")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	if (Arguments[2] <= 0) then citrus.Player.Notify(Player, "Unable to donate negative points!", 1) return end
	
	-- Check Player.
	if (Player == Arguments[1]) then
		citrus.Player.Notify(Player, "Unable to donate to self!", 1)
		
		-- Return.
		return
	end
	
	-- Check Has.
	if (PLUGIN.Has(Player, Arguments[2])) then
		PLUGIN.Give(Arguments[1], Arguments[2])
		PLUGIN.Take(Player, Arguments[2])
		
		-- Notify All.
		citrus.Player.NotifyAll(Player:Name().." donated "..Arguments[2].." point(s) to "..Arguments[1]:Name()..".")
	else
		citrus.Player.Notify(Player, "Unable to afford donation!", 1)
	end
end

-- Get Points.
function COMMAND.GetPoints(Player, Menu, Argument)
	Menu:SliderAdd("Point(s)", function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, 0, 255)
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Standalone Commands", "Donate Points", {{"Player", citrus.QuickMenu.GetPlayer}, {"Point(s)", COMMAND.GetPoints}})

-- Create.
COMMAND:Create()