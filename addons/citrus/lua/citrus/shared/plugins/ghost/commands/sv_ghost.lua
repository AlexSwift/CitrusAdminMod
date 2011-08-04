--[[
Name: "sv_ghost.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("ghost", "M")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("ghost")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Ghost = citrus.PlayerCookies.Get(Player, "Ghost")
	
	-- Check Entity.
	if (Ghost.Entity) then
		PLUGIN.FinishGhosting(Player)
	else
		local Trace = citrus.Utilities.PlayerTrace(Player)
		
		-- Check Entity.
		if (Trace.Entity and !Trace.Entity:IsWorld() and !Trace.Entity:IsPlayer() and !Trace.Entity:IsNPC()) then
			if (gamemode.Call("CanTool", Player, Trace)) then
				PLUGIN.StartGhosting(Player, Trace.Entity)
			end
		else
			citrus.Player.Notify(Player, "Unable to locate valid entity!", 1)
		end
	end
end

-- Create.
COMMAND:Create()