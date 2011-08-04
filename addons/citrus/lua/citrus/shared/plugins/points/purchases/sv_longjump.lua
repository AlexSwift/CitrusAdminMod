--[[
Name: "sv_longjump.lua".
Product: "Citrus (Server Management)".
--]]

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Points")

-- PURCHASE.
local PURCHASE = {}

-- Description.
PURCHASE.Description = "Throws you where you're aiming when you hold sprint and press jump"
PURCHASE.Name = "Long Jump"

-- Key Press.
function PURCHASE.KeyPress(Player, Key)
	local Points = citrus.PlayerVariables.Get(Player, "Points")
	
	-- Check Name.
	if (Points.Purchases[PURCHASE.Name]) then
		if (Player:IsOnGround() and Key == IN_JUMP) then
			if (Player:KeyDown(IN_SPEED)) then
				Player:SetVelocity(Player:GetAimVector() * 500)
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("KeyPress", PURCHASE.KeyPress)

-- On Think.
function PURCHASE.OnThink()
	PURCHASE.Cost = (PLUGIN.Configuration["Increment"] * 300) / PLUGIN.Configuration["Interval"]
end

-- Name.
PLUGIN.Purchases[PURCHASE.Name] = PURCHASE