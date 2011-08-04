--[[
Name: "sv_speaklanguage.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("speaklanguage", false, {{"Language", "string"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Languages")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Language = Arguments[1]
	
	-- Languages.
	local Languages = citrus.PlayerVariables.Get(Player, "Languages")
	
	-- Check Language.
	if (Languages.Known[Language]) then
		Languages.Language = Language
		
		-- Notify.
		citrus.Player.Notify(Player, "You are now speaking "..Language..".")
	else
		citrus.Player.Notify(Player, "You do not know "..Language.."!", 1)
	end
end

-- Create.
COMMAND:Create()