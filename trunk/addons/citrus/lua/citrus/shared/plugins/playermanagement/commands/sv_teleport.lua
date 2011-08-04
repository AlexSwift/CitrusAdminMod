--[[
Name: "sv_teleport.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("teleport")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Player Management")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	if Player:InVehicle() then
		Player:ExitVehicle()
	end
	
	local t = {}
	t.start = Player:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
	t.endpos = Player:GetPos() + Player:EyeAngles():Forward() * 16384
	t.filter = Player
	
	local tr = util.TraceEntity( t, Player )
	
	local pos = tr.HitPos
	
	if pos:Distance( Player:GetPos() ) < 64 then -- Laughable distance
		return
	end

	Player:SetPos( pos )
	Player:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!
end

-- Quick Menu Add.
--COMMAND:QuickMenuAdd("Player Management", "Teleport", {{"Player", citrus.QuickMenu.GetPlayer}})

-- Create.
COMMAND:Create()