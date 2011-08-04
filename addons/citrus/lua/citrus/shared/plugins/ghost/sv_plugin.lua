--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Ghost")

-- Game Support.
PLUGIN.Settings.GameSupport = false
PLUGIN.Settings.Description = "Entities can be controlled by players"
PLUGIN.Settings.Gamemode = {"Sandbox", true}
PLUGIN.Settings.Author = "Conna"

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	citrus.PlayerCookies.New(Player, "Ghost", {})
end

-- On Player Unload.
function PLUGIN:OnPlayerUnload(Player) PLUGIN.FinishGhosting(Player) end

-- Start Ghosting.
function PLUGIN.StartGhosting(Player, Entity)
	local Ghost = citrus.PlayerCookies.Get(Player, "Ghost")
	
	-- Entity.
	Ghost.Entity = Entity
	
	-- Spectate Entity.
	PLUGIN.SpectateEntity(Player, Entity)
end

-- Move Ghost.
function PLUGIN.MoveGhost(Player)
	local Ghost = citrus.PlayerCookies.Get(Player, "Ghost")
	
	-- Check Valid Entity.
	if (ValidEntity(Ghost.Entity)) then
		if (Player:GetMoveType() == MOVETYPE_WALK) then
			PLUGIN.SpectateEntity(Player, Ghost.Entity)
		end
		
		-- Physics Object.
		local PhysicsObject = Ghost.Entity:GetPhysicsObject()
		
		-- Check Valid Entity.
		if (ValidEntity(PhysicsObject)) then
			local Mass = PhysicsObject:GetMass() * 50
			
			-- Check Key Down.
			if (Player:KeyDown(IN_FORWARD)) then
				PhysicsObject:ApplyForceCenter(Player:GetAimVector() * Mass)
			end
		end
		
		-- Set Physics Attacker.
		Ghost.Entity:SetPhysicsAttacker(Player)
	else
		PLUGIN.FinishGhosting(Player)
	end
end

-- Spectate Entity.
function PLUGIN.SpectateEntity(Player, Entity)
	Player:Spectate(OBS_MODE_CHASE)
	Player:SpectateEntity(Entity)
	Player:StripWeapons()
end

-- On Player Think.
function PLUGIN.OnPlayerThink(Player)
	local Ghost = citrus.PlayerCookies.Get(Player, "Ghost")
	
	-- Check Entity.
	if (Ghost.Entity) then PLUGIN.MoveGhost(Player) end
end

-- Finish Ghosting.
function PLUGIN.FinishGhosting(Player)
	local Ghost = citrus.PlayerCookies.Get(Player, "Ghost")
	
	-- Spawn.
	Player:Spawn()
	
	-- Check Valid Entity.
	if (ValidEntity(Ghost.Entity)) then
		Player:SetPos(Ghost.Entity:GetPos() + Vector(0, 0, 32))
	end
	
	-- Entity.
	Ghost.Entity = nil
end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")