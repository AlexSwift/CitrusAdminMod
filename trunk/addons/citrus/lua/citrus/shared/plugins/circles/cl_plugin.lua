--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Circles")

-- Material.
PLUGIN.Material = Material("citrus/circle")

-- Render Screenspace Effects.
function PLUGIN.RenderScreenspaceEffects(Player)
	local EyePos = EyePos()
	local EyeAngles = EyeAngles()
	
	-- Players.
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do
		if (LocalPlayer() != V) then
			if (V:Alive() and V:GetMoveType() != MOVETYPE_OBSERVER) then
				cam.Start3D(EyePos, EyeAngles)
					render.SetMaterial(PLUGIN.Material)
					
					-- Team.
					local Team = V:Team()
					local TeamColor = team.GetColor(Team)
					
					-- Team Color.
					TeamColor = table.Copy(TeamColor)
					TeamColor.a = 150
					
					-- Draw Quad Easy.
					render.DrawQuadEasy(V:GetPos(), Vector(0, 0, 1), 48, 48, TeamColor)
					render.DrawQuadEasy(V:GetPos(), Vector(0, 0, -1), 48, 48, TeamColor)
				cam.End3D()
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("RenderScreenspaceEffects", PLUGIN.RenderScreenspaceEffects)