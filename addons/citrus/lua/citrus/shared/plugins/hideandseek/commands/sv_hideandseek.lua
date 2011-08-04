--[[
Name: "sv_hideandseek.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("hideandseek", "S")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Hide and Seek")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Set Value.
function COMMAND.SetValue(Player, Key, Value)
	PLUGIN.Configuration[Key] = Value
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Hide and Seek")
	Menu:SetIcon("gui/silkicons/plugin")
	Menu:SetReference(COMMAND.Callback)
	
	-- Slider Add.
	Menu:SliderAdd("Countdown", function(Player, Value)
		COMMAND.SetValue(Player, "Countdown", Value)
		
		-- Notify All.
		citrus.Player.NotifyAll("Countdown for Hide and Seek set to "..Value..".")
	end, 1, 250, {Value = PLUGIN.Configuration["Countdown"]})
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Hide and Seek")

-- Create.
COMMAND:Create()