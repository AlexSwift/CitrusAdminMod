--[[
Name: "sv_redo.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("title", "B", { { "Title", "string" } })

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Titles")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

function COMMAND.SetTitle( Player, ttl )
	citrus.PlayerVariables.Set( Player, "Title", ttl )
	citrus.PlayerInformation.Set(Player, "Public", "Title", ttl)
	
	citrus.Player.Notify(Player, "Title set to "..ttl..".")
end

function COMMAND.OnInitialSpawn( Player )
	timer.Simple( 2, function()
		local title = citrus.PlayerVariables.Get( Player, "Title" )
		
		if not title or title == nil then
			title = ""
		end
		
		citrus.PlayerInformation.Set(Player, "Public", "Title", title)
	end)
end
PLUGIN:HookAdd( "PlayerInitialSpawn", COMMAND.OnInitialSpawn )

-- Callback.
function COMMAND.Callback(Player, Arguments)
	if (string.len(Arguments[1]) > 32) then
		citrus.Player.Notify(Player, "Unable to use title with greater than 32 characters!", 1)
		
		-- Return.
		return
	end
	COMMAND.SetTitle( Player, Arguments[1] )
end

COMMAND:QuickMenuAdd("Player Management", "Title", {{"Title", citrus.QuickMenu.GetText}}, "gui/silkicons/application")

-- Create.
COMMAND:Create()