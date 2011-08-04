--[[
Name: "sv_superspeed.lua".
Product: "Citrus (Server Management)".
--]]

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Points")

-- PURCHASE.
local PURCHASE = {}

-- Description.
PURCHASE.Description = "Maximum running speed is dramatically increased"
PURCHASE.Cost = 2
PURCHASE.Name = "Super Speed"

-- On Purchase.
function PURCHASE.OnPurchase(Player) PURCHASE.OnPlayerSpawn(Player) end

-- On Player Spawn.
function PURCHASE.OnPlayerSpawn(Player)
	local Points = citrus.PlayerVariables.Get(Player, "Points")
	
	-- Check Name.
	if (Points.Purchases[PURCHASE.Name]) then
		PLUGIN:TimerCreate(false, FrameTime() * 0.5, 1, function()
			Player:SetRunSpeed(1000)
		end)
	end
end

-- On Think.
function PURCHASE.OnThink()
	PURCHASE.Cost = (PLUGIN.Configuration["Increment"] * 300) / PLUGIN.Configuration["Interval"]
end

-- Name.
PLUGIN.Purchases[PURCHASE.Name] = PURCHASE