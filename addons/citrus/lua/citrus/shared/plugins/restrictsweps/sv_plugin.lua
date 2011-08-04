--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Restrict SWEPs")

-- Description.
PLUGIN.Settings.Description = "SWEPs can be restricted from use"
PLUGIN.Settings.Gamemode = {"Sandbox", false}
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Restrict SWEPs"]

-- On Load.
function PLUGIN:OnLoad()
	concommand.Add("gm_giveswep", PLUGIN.GiveSWEP)
	concommand.Add("gm_spawnswep", PLUGIN.SpawnSWEP)
	
	-- Configuration.
	local Configuration = citrus.Utilities.TableLoad("plugins/restrictsweps.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/restrictsweps.txt", PLUGIN.Configuration)
end

-- On Unload.
function PLUGIN:OnUnload()
	concommand.Add("gm_giveswep", CCGiveSWEP)
	concommand.Add("gm_spawnswep", CCSpawnSWEP)
end

-- Give SWEP.
function PLUGIN.GiveSWEP(Player, Command, Arguments)
	if (!Arguments[1]) then return false end
	
	-- SWEP.
	local SWEP = weapons.GetStored(Arguments[1])
	
	-- Check SWEP.
	if (!SWEP) then return false end
	
	-- Check Spawnable.
	if (!SWEP.Spawnable and !citrus.Access.Has(Player, PLUGIN.Configuration["Administrator Access"])) then
		citrus.Player.Notify(Player, citrus.Access.GetName(PLUGIN.Configuration["Administrator Access"], "or").." access required!", 1)
		
		-- Return False.
		return false
	else
		if (!citrus.Access.Has(Player, PLUGIN.Configuration["Access"])) then
			citrus.Player.Notify(Player, citrus.Access.GetName(PLUGIN.Configuration["Access"], "or").." access required!", 1)
			
			-- Return False.
			return false
		end
	end
	
	-- Give.
	Player:Give(SWEP.Classname)
end

-- Spawn SWEP.
function PLUGIN.SpawnSWEP(Player, Command, Arguments)
	if (!Arguments[1]) then return false end
	
	-- SWEP.
	local SWEP = weapons.GetStored(Arguments[1])
	
	-- Check SWEP.
	if (!SWEP) then return false end
	
	-- Check Spawnable.
	if (!SWEP.Spawnable and !citrus.Access.Has(Player, PLUGIN.Configuration["Administrator Access"])) then
		citrus.Player.Notify(Player, citrus.Access.GetName(PLUGIN.Configuration["Administrator Access"], "or").." access required!", 1)
		
		-- Return False.
		return false
	else
		if (!citrus.Access.Has(Player, PLUGIN.Configuration["Access"])) then
			citrus.Player.Notify(Player, citrus.Access.GetName(PLUGIN.Configuration["Access"], "or").." access required!", 1)
			
			-- Return False.
			return false
		end
	end
	
	-- Trace.
 	local Trace = Player:GetEyeTraceNoCursor()
	
	-- Check Hit.
 	if (!Trace.Hit) then return end
	
	-- Entity.
 	local Entity = ents.Create(SWEP.Classname)
	
	-- Check Valid Entity.
 	if (ValidEntity(Entity)) then
 		Entity:SetPos(Trace.HitPos + Trace.HitNormal * 32)
 		Entity:Spawn()
 	end 
end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")