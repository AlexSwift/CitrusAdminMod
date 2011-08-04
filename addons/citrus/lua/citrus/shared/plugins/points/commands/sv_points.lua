--[[
Name: "sv_points.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("points", "S")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Points")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Points")
	Menu:SetIcon("gui/silkicons/star")
	Menu:SetReference(COMMAND.Callback)
	
	-- Slider Add.
	Menu:SliderAdd("Default", function(Player, Value)
		PLUGIN.Configuration["Default"] = Value
		
		-- Notify All.
		citrus.Player.NotifyAll( "Default for Points set to "..Value..".")
	end, 1, 250, {Value = PLUGIN.Configuration["Default"]})
	Menu:SliderAdd("Interval", function(Player, Value)
		PLUGIN.Configuration["Interval"] = Value
		
		-- Notify All.
		citrus.Player.NotifyAll("Interval for Points set to "..Value..".")
	end, 1, 250, {Value = PLUGIN.Configuration["Interval"]})
	Menu:SliderAdd("Increment", function(Player, Value)
		PLUGIN.Configuration["Increment"] = Value
		
		-- Notify All.
		citrus.Player.NotifyAll("Increment for Points set to "..Value..".")
	end, 1, 250, {Value = PLUGIN.Configuration["Increment"]})
	Menu:CheckBoxAdd("Purchases", function(Player, Value)
		PLUGIN.Configuration["Purchases"] = Value
		
		-- Notify All.
		citrus.Player.NotifyAll("Purchases for Points set to "..tostring(Value == 1)..".")
	end, PLUGIN.Configuration["Purchases"])
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Points")

-- Create.
COMMAND:Create()