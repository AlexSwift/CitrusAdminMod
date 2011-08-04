--[[
Name: "sv_doubledamage.lua".
Product: "Citrus (Server Management)".
--]]

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Points")

-- PURCHASE.
local PURCHASE = {}

-- Description.
PURCHASE.Description = "Damage done to a player or an NPC is doubled"
PURCHASE.Name = "Double Damage"

-- Scale Damage.
function PURCHASE.ScaleDamage(Entity, HitGroup, DamageInfo)
	local Attacker = DamageInfo:GetAttacker()
	local IsPlayer = Attacker:IsPlayer()
	
	-- Check Is Player.
	if (IsPlayer) then
		local Points = citrus.PlayerVariables.Get(Attacker, "Points")
		
		-- Check Name.
		if (Points.Purchases[PURCHASE.Name]) then
			DamageInfo:ScaleDamage(2)
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("ScalePlayerDamage", PURCHASE.ScaleDamage)
PLUGIN:HookAdd("ScaleNPCDamage", PURCHASE.ScaleDamage)

-- On Think.
function PURCHASE.OnThink()
	PURCHASE.Cost = (PLUGIN.Configuration["Increment"] * 240) / PLUGIN.Configuration["Interval"]
end

-- Name.
PLUGIN.Purchases[PURCHASE.Name] = PURCHASE