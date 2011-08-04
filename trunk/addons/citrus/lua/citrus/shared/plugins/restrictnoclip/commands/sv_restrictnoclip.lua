--[[
Name: "sv_restrictnoclip.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("restrictnoclip", "S")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Restrict NoClip")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Restrict NoClip")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetReference(COMMAND.Callback)
	
	-- Callback.
	local function Callback(Access, Value)
		if (string.find(PLUGIN.Configuration["Access"], Access)) then
			if (!Value) then
				PLUGIN.Configuration["Access"] = string.gsub(PLUGIN.Configuration["Access"], Access, "")
			end
		else
			if (Value) then
				PLUGIN.Configuration["Access"] = PLUGIN.Configuration["Access"]..Access
			end
		end
	end
	
	-- For Loop.
	for K, V in pairs(citrus.Access.Stored) do
		Menu:CheckBoxAdd(K.." ("..V..")", function(Player, Value)
			Callback(K, Value)
		end, string.find(PLUGIN.Configuration["Access"], K) != nil)
	end
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Restrict NoClip")

-- Create.
COMMAND:Create()