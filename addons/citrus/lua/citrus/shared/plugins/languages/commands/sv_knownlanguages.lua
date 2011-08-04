--[[
Name: "sv_knownlanguages.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("knownlanguages")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Languages")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Known Languages")
	Menu:SetIcon("gui/silkicons/page")
	Menu:SetReference(COMMAND.Callback)
	
	-- For Loop.
	for K, V in pairs(citrus.PlayerVariables.Get(Player, "Languages").Known) do
		Menu:ButtonAdd(V, function()
			citrus.PlayerVariables.Get(Player, "Languages").Language = V
			
			-- Notify.
			citrus.Player.Notify(Player, "You are now speaking "..V..".")
		end)
	end
	
	-- Send.
	Menu:Send()
end

-- Create.
COMMAND:Create()