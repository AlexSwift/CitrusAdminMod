--[[
Name: "sv_createlanguage.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("createlanguage", false, {{"Language", "string"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Languages")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Language = Arguments[1]
	
	-- Check Language.
	if (!PLUGIN.Languages[Language]) then
		PLUGIN.Languages[Language] = Language
		
		-- Get.
		citrus.PlayerVariables.Get(Player, "Languages").Known[Language] = Language
		
		-- Notify.
		citrus.Player.Notify(Player, "Language "..Language.." created.")
	else
		citrus.Player.Notify(Player, Language.." is already an existing language!", 1)
	end
end

-- Create.
COMMAND:Create()