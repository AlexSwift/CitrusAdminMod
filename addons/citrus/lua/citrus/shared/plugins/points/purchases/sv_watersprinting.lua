--[[
Name: "sv_watersprinting.lua".
Product: "Citrus (Server Management)".
--]]

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Points")

-- PURCHASE.
local PURCHASE = {}

-- Description.
PURCHASE.Description = "Allows sprinting across the surface of water"
PURCHASE.Name = "Water Sprinting"

-- Move.
function PURCHASE.Move(Player, MoveData)
	local Points = citrus.PlayerVariables.Get(Player, "Points")
	
	-- Check Name.
	if (Points.Purchases[PURCHASE.Name]) then
		if (Player:KeyDown(IN_SPEED)) then
			if (Player:KeyDown(IN_FORWARD) or Player:KeyDown(IN_BACK) or Player:KeyDown(IN_LEFT)
			or Player:KeyDown(IN_RIGHT) or Player:KeyDown(IN_MOVELEFT) or Player:KeyDown(IN_MOVERIGHT)) then
				local Position = Player:GetPos()
				local WaterLevel = Player:WaterLevel()
				local Trace = util.TraceLine({start = Position, endpos = Position + Vector(0, 0, -1), filter = Player, mask = -1})
				
				-- Check Water Level.
				if (WaterLevel > 0 and WaterLevel < 3 and Trace.StartSolid) then
					local Velocity = MoveData:GetVelocity()
					
					-- Check Water Level.
					if (WaterLevel > 1) then
						Velocity.z = 2000
					else
						Velocity.z = 10
					end
					
					-- Set Velocity.
					MoveData:SetVelocity(Velocity)
				end
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("Move", PURCHASE.Move)

-- On Think.
function PURCHASE.OnThink()
	PURCHASE.Cost = (PLUGIN.Configuration["Increment"] * 240) / PLUGIN.Configuration["Interval"]
end

-- Name.
PLUGIN.Purchases[PURCHASE.Name] = PURCHASE