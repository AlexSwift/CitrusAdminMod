--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Player Grabbing")

-- Description.
PLUGIN.Settings.Description = "Players can be grabbed with the physgun"
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Player Grabbing"]

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/playergrabbing.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/playergrabbing.txt", PLUGIN.Configuration)
end

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	citrus.PlayerCookies.New(Player, "Player Grabbing", {NoClip = false, Active = false})
end

-- Physgun Pickup.
function PLUGIN.PhysgunPickup(Player, Entity)
	if (Entity:IsPlayer() and citrus.Access.Has(Player, PLUGIN.Configuration["Access"])) then
		if (Entity:GetMoveType() == MOVETYPE_NOCLIP) then
			citrus.PlayerCookies.Get(Entity, "Player Grabbing").NoClip = true
		end
		
		-- Picked Up.
		citrus.PlayerCookies.Get(Entity, "Player Grabbing").Active = true
		
		-- Freeze.
		Entity:Freeze(true)
		Entity:SetMoveType(MOVETYPE_NOCLIP)
		
		-- Return True.
		return true
	end
end

-- Hook Add.
PLUGIN:HookAdd("PhysgunPickup", PLUGIN.PhysgunPickup)

-- On Player Second.
function PLUGIN.OnPlayerSecond(Player)
	local PlayerGrabbing = citrus.PlayerCookies.Get(Player, "Player Grabbing")
	
	-- Check Active.
	if (PlayerGrabbing.Active) then
		Player:Freeze(true)
		Player:SetMoveType(MOVETYPE_NOCLIP)
	end
end

-- Physgun Drop.
function PLUGIN.PhysgunDrop(Player, Entity)
	local IsPlayer = Entity:IsPlayer()
	
	-- Check Is Player.
	if (IsPlayer) then
		if (!citrus.PlayerCookies.Get(Entity, "Player Grabbing").NoClip) then
			Entity:SetMoveType(MOVETYPE_WALK)
		else
			citrus.PlayerCookies.Get(Entity, "Player Grabbing").NoClip = false
		end
		
		-- Get.
		citrus.PlayerCookies.Get(Entity, "Player Grabbing").Active = false
		
		-- Freeze.
		Entity:Freeze(false)
	end
end

-- Hook Add.
PLUGIN:HookAdd("PhysgunDrop", PLUGIN.PhysgunDrop)

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")