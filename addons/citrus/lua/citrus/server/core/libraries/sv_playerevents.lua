--[[
Name: "sv_playerevents.lua".
Product: "Citrus (Server Management)".
--]]

citrus.PlayerEvent = {}
citrus.PlayerEvents = {}
citrus.PlayerEvents.Stored = {}

-- Use Gravity Gun.
citrus.PlayerEvent.UsePhysicsGun = 1
citrus.PlayerEvent.UseGravityGun = 2
citrus.PlayerEvent.EnterVehicle = 3
citrus.PlayerEvent.SpawnObject = 4
citrus.PlayerEvent.TakeDamage = 5
citrus.PlayerEvent.UseCommand = 6
citrus.PlayerEvent.UseTool = 7
citrus.PlayerEvent.Suicide = 8
citrus.PlayerEvent.NoClip = 9
citrus.PlayerEvent.Say = 10
citrus.PlayerEvent.Use = 11

-- On Player Set Variables.
function citrus.PlayerEvents.OnPlayerSetVariables(Player)
	citrus.PlayerCookies.New(Player, "Player Events", {})
end

-- Add.
citrus.Hooks.Add("OnPlayerSetVariables", citrus.PlayerEvents.OnPlayerSetVariables)

-- Allow.
function citrus.PlayerEvents.Allow(Player, Name, Event, Boolean)
	if (Player) then
		local PlayerEvents = citrus.PlayerCookies.Get(Player, "Player Events")
		
		-- Name.
		PlayerEvents[Name] = PlayerEvents[Name] or {}
		PlayerEvents[Name][Event] = Boolean
	else
		citrus.PlayerEvents.Stored[Name] = citrus.PlayerEvents.Stored[Name] or {}
		citrus.PlayerEvents.Stored[Name][Event] = Boolean
	end
end

-- Allow All.
function citrus.PlayerEvents.AllowAll(Player, Name, Boolean)
	if (Player) then
		local PlayerEvents = citrus.PlayerCookies.Get(Player, "Player Events")
		
		-- Check Name.
		if (PlayerEvents[Name]) then
			for K, V in pairs(PlayerEvents[Name]) do PlayerEvents[Name][K] = Boolean end
		end
	else
		if (citrus.PlayerEvents.Stored[Name]) then
			for K, V in pairs(citrus.PlayerEvents.Stored[Name]) do
				citrus.PlayerEvents.Stored[Name][K] = Boolean
			end
		end
	end
end

-- Is Allowed.
function citrus.PlayerEvents.IsAllowed(Player, Event)
	for K, V in pairs(citrus.PlayerEvents.Stored) do
		for K2, V2 in pairs(V) do
			if (K2 == Event) then if (!V2) then return false end end
		end
	end
	
	-- PlayerEvents.
	local PlayerEvents = citrus.PlayerCookies.Get(Player, "Player Events")
	
	-- Check PlayerEvents.
	if (PlayerEvents) then
		for K, V in pairs(PlayerEvents) do
			for K2, V2 in pairs(V) do
				if (K2 == Event) then if (!V2) then return false end end
			end
		end
	end
	
	-- Return True.
	return true
end

-- Player Spawn Object.
function citrus.PlayerEvents.PlayerSpawnObject(Player)
	local IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.SpawnObject)
	
	-- Check Is Allowed.
	if (!IsAllowed) then return false end
end

-- Add.
hook.Add("PlayerSpawnObject", "citrus.PlayerEvents.PlayerSpawnObject", citrus.PlayerEvents.PlayerSpawnObject)
hook.Add("PlayerSpawnSENT", "citrus.PlayerEvents.PlayerSpawnObject", citrus.PlayerEvents.PlayerSpawnObject)
hook.Add("PlayerSpawnSWEP", "citrus.PlayerEvents.PlayerSpawnObject", citrus.PlayerEvents.PlayerSpawnObject)
hook.Add("PlayerSpawnVehicle ", "citrus.PlayerEvents.PlayerSpawnObject", citrus.PlayerEvents.PlayerSpawnObject)
hook.Add("PlayerSpawnNPC", "citrus.PlayerEvents.PlayerSpawnObject", citrus.PlayerEvents.PlayerSpawnObject)

-- Player NoClip.
function citrus.PlayerEvents.PlayerNoClip(Player)
	local IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.NoClip)
	
	-- Check Is Allowed.
	if (!IsAllowed) then return false end
end

-- Add.
hook.Add("PlayerNoClip", "citrus.PlayerEvents.PlayerNoClip", citrus.PlayerEvents.PlayerNoClip)

-- Can Tool.
function citrus.PlayerEvents.CanTool(Player)
	local IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.UseTool)
	
	-- Check Is Allowed.
	if (!IsAllowed) then return false end
end

-- Add.
hook.Add("CanTool", "citrus.PlayerEvents.CanTool", citrus.PlayerEvents.CanTool)

-- Can Player Suicide.
function citrus.PlayerEvents.CanPlayerSuicide(Player)
	local IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.Suicide)
	
	-- Check Is Allowed.
	if (!IsAllowed) then return false end
end

-- Add.
hook.Add("CanPlayerSuicide", "citrus.PlayerEvents.CanPlayerSuicide", citrus.PlayerEvents.CanPlayerSuicide)

-- Physgun Pickup.
function citrus.PlayerEvents.PhysgunPickup(Player)
	local IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.UsePhysicsGun)
	
	-- Check Is Allowed.
	if (!IsAllowed) then return false end
end

-- Add.
hook.Add("PhysgunPickup", "citrus.PlayerEvents.PhysgunPickup", citrus.PlayerEvents.PhysgunPickup)

-- Grav Gun Pickup Allowed.
function citrus.PlayerEvents.GravGunPickupAllowed(Player)
	local IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.UseGravityGun)
	
	-- Check Is Allowed.
	if (!IsAllowed) then return false end
end

-- Add.
hook.Add("GravGunPickupAllowed", "citrus.PlayerEvents.GravGunPickupAllowed", citrus.PlayerEvents.GravGunPickupAllowed)

-- Can Player Enter Vehicle.
function citrus.PlayerEvents.CanPlayerEnterVehicle(Player)
	local IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.EnterVehicle)
	
	-- Check Is Allowed.
	if (!IsAllowed) then return false end
end

-- Add.
hook.Add("CanPlayerEnterVehicle", "citrus.PlayerEvents.CanPlayerEnterVehicle", citrus.PlayerEvents.CanPlayerEnterVehicle)

-- Player Should Take Damage.
function citrus.PlayerEvents.PlayerShouldTakeDamage(Player)
	local IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.TakeDamage)
	
	-- Check Is Allowed.
	if (!IsAllowed) then return false end
end

-- Add.
hook.Add("PlayerShouldTakeDamage", "citrus.PlayerEvents.PlayerShouldTakeDamage", citrus.PlayerEvents.PlayerShouldTakeDamage)

-- Player Use.
function citrus.PlayerEvents.PlayerUse(Player, Entity)
	local Access = Entity:GetKeyValues()["citrus_access"]
	
	-- Check Access.
	if (Access) then
		if (!citrus.Access.Has(Player, Access)) then
			citrus.Player.Notify(Player, citrus.Access.GetName(Access, "or").." access required!", 1)
			
			-- Return False.
			return false
		end
	end
	
	-- Allowed.
	local IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.Use)
	
	-- Check Is Allowed.
	if (!IsAllowed) then return false end
end

-- Add.
hook.Add("PlayerUse", "citrus.PlayerEvents.PlayerUse", citrus.PlayerEvents.PlayerUse)

-- Run Console Command.
local RunConsoleCommand = concommand.Run

-- Run.
function concommand.Run(Player, Command, Arguments)
	if (Command == "gm_giveswep" or Command == "gm_spawnswep") then
		local IsAllowed = citrus.PlayerEvents.IsAllowed(Player, citrus.PlayerEvent.SpawnObject)
		
		-- Check Is Allowed.
		if (!IsAllowed) then return false end
	end
	
	-- Run Console Command.
	RunConsoleCommand(Player, Command, Arguments)
end