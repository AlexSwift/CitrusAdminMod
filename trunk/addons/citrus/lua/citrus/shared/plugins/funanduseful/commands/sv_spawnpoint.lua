--[[
Name: "sv_redo.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("spawnpoint", "B")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Fun and Useful")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

function COMMAND.SetSpawn( Player )
	Player.SpawnPos = Player:GetPos()
	
	citrus.Player.Notify(Player, "Spawnpoint set!")
end

function COMMAND.OnSpawn( Player )
	if (Player.SpawnPos) then
		Player:SetPos( Player.SpawnPos )
	end
end
PLUGIN:HookAdd( "PlayerSpawn", COMMAND.OnSpawn )

-- Callback.
function COMMAND.Callback(Player, Arguments)
	COMMAND.SetSpawn( Player )
end

-- Create.
COMMAND:Create()