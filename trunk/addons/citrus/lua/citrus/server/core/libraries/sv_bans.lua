--[[
Name: "sv_bans.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Bans = {}
citrus.Bans.Stored = {}

-- Add.
function citrus.Bans.Add(Player, Enforcer, Duration, Reason, Kick)
	local Table = {}
	
	-- Enforcer.
	Enforcer = Enforcer or "N/A"
	Duration = Duration or 0
	Reason = Reason or "N/A"
	
	-- Steam ID.
	Table.SteamID = Player:SteamID()
	Table.IPAddress = Player:IPAddress()
	Table.Enforcer = Enforcer
	Table.Duration = Duration
	Table.Reason = Reason
	Table.Group = citrus.Player.GetGroup(Player).Name
	Table.Name = Player:Name()
	
	-- Check Duration.
	if (Duration > 0) then
		Table.Lifted = os.time() + Duration
	else
		Table.Lifted = 0
	end
	
	-- Steam ID.
	citrus.Bans.Stored[Table.SteamID] = Table
	
	-- Call.
	citrus.Hooks.Call("OnPlayerBanned", Player, citrus.Bans.Stored[Table.SteamID])
	
	-- Check Kick.
	if (Kick) then
		if (Duration == 0) then
			Duration = "Permanant"
		else
			Duration = citrus.Utilities.GetFormattedTime(Duration, "%hh %mm %ss")
		end
		
		-- Overlay Add.
		citrus.Player.OverlayAdd(Player, "Banned", "Banned", "Reason: "..Reason.."\nEnforcer: "..Enforcer.."\nDuration: "..Duration, 255)
		
		-- Simple.
		timer.Simple(5, function()
			if (Duration == "Permanant") then
				citrus.Player.Kick(Player, "Banned Permanantly")
			else
				citrus.Player.Kick(Player, "Banned for "..Duration)
			end
		end)
	end
end

-- Offline Add.
function citrus.Bans.OfflineAdd(SteamID, Name, Enforcer, Duration, Reason)
	SteamID = string.upper(SteamID)
	
	-- Table.
	local Table = {}
	
	-- Name.
	Name = Name or ID
	Enforcer = Enforcer or "N/A"
	Duration = Duration or 0
	Reason = Reason or "N/A"
	
	-- Steam ID.
	Table.SteamID = SteamID
	Table.IPAddress = "N/A"
	Table.Enforcer = Enforcer
	Table.Duration = Duration
	Table.Reason = Reason
	Table.Group = "N/A"
	Table.Name = Name
	
	-- Check Duration.
	if (Duration > 0) then
		Table.Lifted = os.time() + Duration
	else
		Table.Lifted = 0
	end
	
	-- Steam ID.
	citrus.Bans.Stored[Table.SteamID] = Table
	
	-- Call.
	citrus.Hooks.Call("OnPlayerBanned", false, citrus.Bans.Stored[Table.SteamID])
end

-- Get All.
function citrus.Bans.GetAll() return citrus.Bans.Stored end

-- Remove.
function citrus.Bans.Remove(SteamID)
	citrus.Hooks.Call("OnPlayerUnbanned", citrus.Bans.Stored[SteamID])
	
	-- ID.
	citrus.Bans.Stored[SteamID] = nil
end

-- On Second.
function citrus.Bans.OnSecond()
	for K, V in pairs(citrus.Bans.Stored) do
		if (citrus.Bans.HasElapsed(V)) then citrus.Bans.Remove(K) end
	end
end

-- Add.
citrus.Hooks.Add("OnSecond", citrus.Bans.OnSecond)

-- Has Elapsed.
function citrus.Bans.HasElapsed(Ban)
	local Remaining = citrus.Bans.GetRemaining(Ban)
	
	-- Check Remainding Time.
	if (Remaining == 0 and Ban.Duration != 0) then return true end
	
	-- Return False.
	return false
end

-- Get Remaining.
function citrus.Bans.GetRemaining(Ban) return math.max(Ban.Lifted - os.time(), 0) end

-- Player Initial Spawn.
function citrus.Bans.PlayerInitialSpawn(Player)
	local SteamID = Player:SteamID()
	
	-- Check Steam ID.
	if (citrus.Bans.Stored[SteamID]) then
		local Ban = citrus.Bans.Stored[SteamID]
		local Remaining = citrus.Bans.GetRemaining(Ban)
		
		-- Check Duration.
		if (Ban.Duration == 0) then
			citrus.Player.Kick(Player, "Banned Permanantly")
		else
			citrus.Player.Kick(Player, "Banned for "..citrus.Utilities.GetFormattedTime(Remaining, "%hh %mm %ss"))
		end
	end
end

-- Add.
hook.Add("PlayerInitialSpawn", "citrus.Bans.PlayerInitialSpawn", citrus.Bans.PlayerInitialSpawn)

-- Initialize.
function citrus.Bans.Initialize()
	citrus.Bans.Stored = citrus.Utilities.TableLoad("bans.txt") or {}
end

-- Add.
hook.Add("Initialize", "citrus.Bans.Initialize", citrus.Bans.Initialize)
	
-- On Save Variables.
function citrus.Bans.OnSaveVariables()
	citrus.Utilities.TableSave("bans.txt", citrus.Bans.Stored)
end

-- Add.
citrus.Hooks.Add("OnSaveVariables", citrus.Bans.OnSaveVariables)