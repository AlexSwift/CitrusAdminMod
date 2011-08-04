--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Entity Guard")

-- Game Support
PLUGIN.Settings.GameSupport = false
PLUGIN.Settings.Description = "Entities are guarded from players other than their owner"
PLUGIN.Settings.Gamemode = {"Sandbox", true}
PLUGIN.Settings.Author = "Conna"

-- Configuration.
PLUGIN.Configuration = citrus.ParseINI:New("lua/"..PLUGIN.FilePath.."/sv_configuration.ini"):Parse()["Entity Guard"]

-- On Load.
function PLUGIN:OnLoad()
	local Configuration = citrus.Utilities.TableLoad("plugins/entityguard.txt") or {}
	
	-- Merge.
	table.Merge(PLUGIN.Configuration, Configuration)
end

-- On Save Variables.
function PLUGIN.OnSaveVariables()
	citrus.Utilities.TableSave("plugins/entityguard.txt", PLUGIN.Configuration)
end

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	citrus.PlayerCookies.New(Player, "Entity Guard", {Friends = {}, Message = 0})
	
	-- Timer Remove.
	PLUGIN:TimerRemove(citrus.Player.GetUniqueID(Player))
end

-- Player Disconnected.
function PLUGIN.PlayerDisconnected(Player)
	if (PLUGIN.Configuration["Automatic Cleanup"]) then
		local UniqueID = citrus.Player.GetUniqueID(Player)
		local Name = Player:Name()
		
		-- Timer Create.
		PLUGIN:TimerCreate(UniqueID, 300, 1, function()
			local Entities = ents.GetAll()
			
			-- For Loop.
			for K, V in pairs(Entities) do
				if (V:GetVar("Entity Guard", false) == UniqueID) then
					if (!PLUGIN.IsWorlds(V)) then
						local IsPlayer = V:IsPlayer()
						local IsWorld = V:IsWorld()
						
						-- Check Is Player.
						if (!IsPlayer and !IsWorld) then V:Remove() end
					end
				end
			end
			
			-- Notify All.
			citrus.Player.NotifyAll(Name.."'s entities have been removed.")
			
			-- CC_Cleanup.
			cleanup.CC_Cleanup(Player, "gmod_cleanup", {})
		end)
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerDisconnected", PLUGIN.PlayerDisconnected)

-- Give Entity.
function PLUGIN.GiveEntity(Player, Entity)
	if (ValidEntity(Entity)) then
		local UniqueID = citrus.Player.GetUniqueID(Player)
		local Name = Player:Name()
		
		-- Set Var.
		Entity:SetVar("Entity Guard", UniqueID)
		
		-- Set Sandbox ID.
		PLUGIN.SetSandboxID(Entity, UniqueID)
	end
end

-- Set Worlds.
function PLUGIN.SetWorlds(Entity)
	Entity:SetVar("Entity Guard", "World")
	
	-- Set Sandbox ID.
	PLUGIN.SetSandboxID(Entity, "World")
end

-- Set Shared.
function PLUGIN.SetShared(Entity)
	Entity:SetVar("Entity Guard", "Shared")
	
	-- Set Sandbox ID.
	PLUGIN.SetSandboxID(Entity, "Shared")
end

-- Is Worlds.
function PLUGIN.IsWorlds(Entity)
	return (Entity:GetVar("Entity Guard", false) == "World")
end

-- Is Abandoned.
function PLUGIN.IsAbandoned(Entity)
	if (PLUGIN.HasOwner(Entity) and !PLUGIN.GetOwner(Entity)) then return true end
	
	-- Return False.
	return false
end

-- Is Shared.
function PLUGIN.IsShared(Entity)
	return (Entity:GetVar("Entity Guard", false) == "Shared")
end

-- Has Owner.
function PLUGIN.HasOwner(Entity)
	return (Entity:GetVar("Entity Guard", false) != false)
end

-- Set Sandbox ID.
function PLUGIN.SetSandboxID(Entity, ID)
	for K, V in pairs(g_SBoxObjects) do
		for K2, V2 in pairs(V) do
			for K3, V3 in pairs(V2) do
				if (E == Entity) then
					g_SBoxObjects[K][K2][K3] = nil
					
					-- SBox Objects.
					g_SBoxObjects[ID] = g_SBoxObjects[ID] or {}
					g_SBoxObjects[ID][K2] = g_SBoxObjects[ID][K2] or {}
					
					-- K2.
					g_SBoxObjects[ID][K2][#g_SBoxObjects[ID][K2] + 1] = Entity
					
					-- Break.
					break
				end
			end
		end
	end
	
	-- For Loop.
	for K, V in pairs(GAMEMODE.CameraList) do
		for K2, V2 in pairs(V) do
			if (V2 == Entity) then
				GAMEMODE.CameraList[K][K2] = nil
				
				-- Camera List.
				GAMEMODE.CameraList[ID] = GAMEMODE.CameraList[ID] or {}
				
				-- Check Camera List.
				if (GAMEMODE.CameraList[ID][K2] and GAMEMODE.CameraList[ID][K2] != NULL) then
					GAMEMODE.CameraList[ID][K2]:Remove()
				end
				
				-- Camera List.
				GAMEMODE.CameraList[ID][K2] = GAMEMODE.CameraList[ID][K2] or Entity
				
				-- Break.
				break
			end
		end
	end
end

-- Physgun Pickup.
function PLUGIN.PhysgunPickup(Player, Entity)
	if (PLUGIN.Configuration["Physgun Protection"]) then
		if (ValidEntity(Entity)) then
			local IsPlayer = Entity:IsPlayer()
			
			-- Time.
			local Time = RealTime()
			
			-- Check Is Player.
			if (!IsPlayer) then
				local Success, Error = PLUGIN.CanManage(Player, Entity)
				
				-- Check Success.
				if (!Success) then
					local EntityGuard = citrus.PlayerCookies.Get(Player, "Entity Guard")
					
					-- Check Message.
					if (EntityGuard.Message < Time) then
						citrus.Player.Notify(Player, Error, 1)
						
						-- Message.
						EntityGuard.Message = Time + 1
					end
					
					-- Return False.
					return false
				end
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("PhysgunPickup", PLUGIN.PhysgunPickup)

-- Grav Gun Punt.
function PLUGIN.GravGunPunt(Player, Entity)
	if (PLUGIN.Configuration["Gravgun Protection"]) then
		if (ValidEntity(Entity)) then
			local IsPlayer = Entity:IsPlayer()
			
			-- Time.
			local Time = RealTime()
			
			-- Check Is Player.
			if (!IsPlayer) then
				local Success, Error = PLUGIN.CanManage(Player, Entity)
				
				-- Check Success.
				if (!Success) then
					local EntityGuard = citrus.PlayerCookies.Get(Player, "Entity Guard")
					
					-- Check Message.
					if (EntityGuard.Message < Time) then
						citrus.Player.Notify(Player, Error, 1)
						
						-- Message.
						EntityGuard.Message = Time + 1
					end
					
					-- Return False.
					return false
				end
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("GravGunPunt", PLUGIN.GravGunPunt)
PLUGIN:HookAdd("GravGunPickupAllowed", PLUGIN.GravGunPunt)

-- On Entity Created.
function PLUGIN.OnEntityCreated(Entity)
	if (ValidEntity(Entity)) then
		local Parent = Entity:GetParent()
		
		-- Check Valid Entity.
		if (ValidEntity(Parent)) then
			local IsPlayer = Parent:IsPlayer()
			
			-- Check Is Player.
			if (IsPlayer) then PLUGIN.GiveEntity(Parent, Entity) end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("OnEntityCreated", PLUGIN.OnEntityCreated)

-- On Player Think.
function PLUGIN.OnPlayerThink(Player)
	local Trace = citrus.Utilities.PlayerTrace(Player)
	
	-- Check Valid Entity.
	if (ValidEntity(Trace.Entity)) then
		if (!PLUGIN.HasOwner(Trace.Entity)) then PLUGIN.GiveEntity(Player, Trace.Entity) end
		
		-- Check Display Owner.
		if (PLUGIN.Configuration["Display Owner"]) then
			local IsPlayer = Trace.Entity:IsPlayer()
			local IsWeapon = Trace.Entity:IsWeapon()
			local IsWorld = Trace.Entity:IsWorld()
			
			-- Check Is Player.
			if (IsPlayer or IsWeapon or IsWorld) then
				citrus.PlayerInformation.Set(Player, "Entity Guard", "Owner", false)
				citrus.PlayerInformation.Set(Player, "Entity Guard", "Class", false)
			else
				local Owner = PLUGIN.GetOwner(Trace.Entity)
				
				-- Class.
				local Class = Trace.Entity:GetClass()
				
				-- Check Display Class.
				if (PLUGIN.Configuration["Display Class"]) then
					citrus.PlayerInformation.Set(Player, "Entity Guard", "Class", Class)
				end
				
				-- Check Owner.
				if (Owner) then
					local Name = Owner:Name()
					
					-- Set.
					citrus.PlayerInformation.Set(Player, "Entity Guard", "Owner", Name)
				else
					if (PLUGIN.IsShared(Trace.Entity)) then
						citrus.PlayerInformation.Set(Player, "Entity Guard", "Owner", "Shared")
					elseif (PLUGIN.IsWorlds(Trace.Entity)) then
						citrus.PlayerInformation.Set(Player, "Entity Guard", "Owner", "World")
					else
						if (PLUGIN.IsAbandoned(Trace.Entity)) then
							citrus.PlayerInformation.Set(Player, "Entity Guard", "Owner", "Abandoned")
						else
							citrus.PlayerInformation.Set(Player, "Entity Guard", "Owner", "Unowned")
						end
					end
				end
			end
		else
			citrus.PlayerInformation.Set(Player, "Entity Guard", "Owner", false)
			citrus.PlayerInformation.Set(Player, "Entity Guard", "Class", false)
		end
	else
		citrus.PlayerInformation.Set(Player, "Entity Guard", "Owner", false)
		citrus.PlayerInformation.Set(Player, "Entity Guard", "Class", false)
	end
end

-- On Physgun Reload.
function PLUGIN.OnPhysgunReload(Weapon, Player)
	if (PLUGIN.Configuration["Physgun Protection"]) then
		local Trace = citrus.Utilities.PlayerTrace(Player)
		
		-- Check Valid Entity.
		if (ValidEntity(Trace.Entity)) then
			local Success, Error = PLUGIN.CanManage(Player, Trace.Entity)
			
			-- Check Success.
			if (!Success) then
				citrus.Player.Notify(Player, Error, 1)
				
				-- Return False.
				return false
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("OnPhysgunReload", PLUGIN.OnPhysgunReload)

-- Player Use.
function PLUGIN.PlayerUse(Player, Entity)
	if (PLUGIN.Configuration["Use Protection"]) then
		local Success, Error = PLUGIN.CanManage(Player, Entity)
		
		-- Check Success.
		if (!Success) then
			if (!PLUGIN.IsWorlds(Entity)) then
				citrus.Player.Notify(Player, Error, 1)
				
				-- Return False.
				return false
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerUse", PLUGIN.PlayerUse)

-- Can Manage.
function PLUGIN.CanManage(Player, Entity)
	local World = Entity:IsWorld()
	
	-- Check World.
	if (World) then return true end
	
	-- Check Has Owner.
	if (!PLUGIN.HasOwner(Entity)) then
		PLUGIN.GiveEntity(Player, Entity)
		
		-- Return True.
		return true
	end
	
	-- Check Has.
	if (citrus.Access.Has(Player, PLUGIN.Configuration["Access"])) then return true end
	
	-- Check Is Worlds.
	if (PLUGIN.IsWorlds(Entity)) then return false, "Unable to manage entity not owned by you!" end
	
	-- Check Is Shared.
	if (PLUGIN.IsShared(Entity)) then return true end
	if (PLUGIN.IsOwnersBuddy(Player, Entity)) then return true end
	if (PLUGIN.GetOwner(Entity) == Player) then return true end
	
	-- Return False.
	return false, "Unable to manage entity not owned by you!"
end

-- Get Owner.
function PLUGIN.GetOwner(Entity)
	local Owner = Entity:GetVar("Entity Guard", false)
	
	-- Check Owner.
	if (Owner) then
		local Players = player.GetAll()
		
		-- For Loop.
		for K, V in pairs(Players) do
			if (citrus.Player.GetUniqueID(V) == Owner) then return V end
		end
	end
	
	-- Return False.
	return false
end

-- Can Player Enter Vehicle.
function PLUGIN.CanPlayerEnterVehicle(Player, Vehicle)
	if (PLUGIN.Configuration["Vehicle Protection"]) then
		local Success, Error = PLUGIN.CanManage(Player, Vehicle)
		
		-- Check Success.
		if (!Success) then
			if (!PLUGIN.IsWorlds(Vehicle)) then
				citrus.Player.Notify(Player, Error, 1)
				
				-- Return False.
				return false
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("CanPlayerEnterVehicle", PLUGIN.CanPlayerEnterVehicle)

-- Can Tool.
function PLUGIN.CanTool(Player, Trace, Tool)
	if (PLUGIN.Configuration["Tool Protection"]) then
		local Mode = 1
		
		-- Check Key Down.
		if (Player:KeyDown(IN_ATTACK2)) then Mode = 2 elseif (Player:KeyDown(IN_RELOAD)) then Mode = 3 end
		
		-- Check Entity.
		if (Trace.Entity) then
			if (ValidEntity(Trace.Entity)) then
				local IsWorld = Trace.Entity:IsWorld()
				
				-- Check Is World.
				if (!IsWorld) then
					if (PLUGIN.IsWorlds(Trace.Entity)) then
						if (Tool == "remover") then
							citrus.Player.Notify(Player, "Unable to remove world entities!", 1)
							
							-- Return False.
							return false
						else
							return
						end
					end
					
					-- Check Tool.
					if (Tool == "remover" and Mode == 2) then
						local Entities = constraint.GetAllConstrainedEntities(Trace.Entity) or {}
						local Count = 0
						
						-- For Loop.
						for K, V in pairs(Entities) do
							if (!PLUGIN.CanManage(Player, V) or PLUGIN.IsWorlds(V)) then Count = Count + 1 end
						end
						
						-- Check Count.
						if (Count > 0) then
							citrus.Player.Notify(Player, "Unable to remove "..Count.." constrained entities!", 1)
							
							-- Return False.
							return false
						end
					elseif (Tool == "nail") then
						local Table = {}
						
						-- start.
						Table.start = Trace.HitPos
						Table.endpos = Trace.HitPos + (Player:GetAimVector() * 16.0)
						Table.filter = {Player, Trace.Entity}
						
						-- Can Tool.
						local CanTool = PLUGIN.CanTool(Player, util.TraceLine(Table), false)
						
						-- Check Can Tool.
						if (!CanTool) then return false end
					else
						local Success, Error = PLUGIN.CanManage(Player, Trace.Entity)
						
						-- Check Success.
						if (!Success) then
							citrus.Player.Notify(Player, Error, 1)
							
							-- Fix Client Side Can Tool.
							PLUGIN.FixClientSideCanTool(Player, Tool, Trace.Entity)
							
							-- Return False.
							return false
						end
					end
				end
			end
		end
		
		-- Check Tool.
		if (!Tool) then return true end
	end
end 

-- Hook Add.
PLUGIN:HookAdd("CanTool", PLUGIN.CanTool)

-- Entity Take Damage.
function PLUGIN.EntityTakeDamage(Entity, Inflictor, Attacker, Damage, DamageInfo)
	if (PLUGIN.Configuration["Damage Protection"]) then
		local IsPlayer = Attacker:IsPlayer()
		
		-- Check Is Player.
		if (!IsPlayer and PLUGIN.GetOwner(Attacker)) then
			Attacker = PLUGIN.GetOwner(Attacker)
			IsPlayer = true
		end
		
		-- Physics Attacker.
		local PhysicsAttacker = Attacker:GetPhysicsAttacker()
		
		-- Check Is Player.
		if (!IsPlayer and ValidEntity(PhysicsAttacker)) then
			Attacker = PhysicsAttacker
			IsPlayer = true
		end
		
		-- Owner.
		local Owner = Attacker:GetOwner()
		
		-- Check Is Player.
		if (!IsPlayer and ValidEntity(Owner)) then
			Attacker = Owner
			IsPlayer = true
		end
		
		-- Check Is Player.
		if (IsPlayer) then
			local IsPlayer = Entity:IsPlayer()
			
			-- Check Is Player.
			if (!IsPlayer) then
				local Success, Error = PLUGIN.CanManage(Attacker, Entity)
				
				-- Check Success.
				if (!Success) then
					if (!PLUGIN.IsWorlds(Entity)) then
						local Time = RealTime()
						
						-- Entity Guard.
						local EntityGuard = citrus.PlayerCookies.Get(Attacker, "Entity Guard")
						
						-- Check Get.
						if (EntityGuard.Message < Time) then
							citrus.Player.Notify(Attacker, Error, 1)
							
							-- Set.
							EntityGuard.Message = Time + 1
						end
						
						-- Check Last On Fire.
						if (!Entity.LastOnFire or Entity.LastOnFire > CurTime() + 0.5) then
							Entity.LastOnFire = nil
							Entity:Extinguish()
						end
						
						-- Extinguish.
						PLUGIN.Extinguish(Entity)
						
						-- Set Damage.
						DamageInfo:SetDamage(0)
					end
				end
			end
		else
			local IsOnFire = Entity:IsOnFire()
			
			-- Check Is On Fire.
			if (IsOnFire) then Entity.LastOnFire = CurTime() end
			
			-- Check Is Damage Type.
			if (DamageInfo:IsDamageType(DMG_BURN)) then
				local Parent = Attacker:GetParent()
				
				-- Check Valid Entity.
				if (ValidEntity(Parent)) then
					if (PLUGIN.GetOwner(Entity) and PLUGIN.GetOwner(Parent)) then
						if (PLUGIN.GetOwner(Entity) != PLUGIN.GetOwner(Parent)) then
							DamageInfo:SetDamage(0)
							
							-- Extinguish.
							Entity:Extinguish()
							
							-- Return.
							return
						end
					end
				end
				
				-- Return.
				return
			elseif (DamageInfo:IsDamageType(DMG_CRUSH)) then
				if (Attacker:GetClass() == "worldspawn") then
					if (PLUGIN.GetOwner(Entity)) then
						DamageInfo:SetDamage(0)
						
						-- Return.
						return
					end
				end
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("EntityTakeDamage", PLUGIN.EntityTakeDamage)

-- Extinguish.
function PLUGIN.Extinguish(Entity)
	local IsOnFire = Entity:IsOnFire()
	
	-- Health.
	local Health = Entity:Health()
	
	-- Check Is On Fire.
	if (!IsOnFire) then
		timer.Simple(FrameTime() * 0.5, function()
			if (ValidEntity(Entity)) then
				Entity:Extinguish()
				Entity:SetHealth(Health)
			end
		end)
	end
end

-- Fix Client Side Can Tool.
function PLUGIN.FixClientSideCanTool(Player, Tool, Entity)
	local Color = Entity:GetColor()
	local Material = Entity:GetMaterial()
	
	-- Check Tool.
	if (Tool == "color") then
		timer.Simple(0.25, function()
			PLUGIN:UsermessageCall("Fix Color", Player, function()
				umsg.Entity(Entity)
				umsg.Short(Color.r)
				umsg.Short(Color.g)
				umsg.Short(Color.b)
				umsg.Short(Color.a)
			end)
		end)
	end
	if (Tool == "material") then
		timer.Simple(0.25, function()
			PLUGIN:UsermessageCall("Fix Material", Player, function()
				umsg.Entity(Entity)
				umsg.String(Material)
			end)
		end)
	end
end

-- Is Owners Buddy.
function PLUGIN.IsOwnersBuddy(Player, Entity)
	local Owner = PLUGIN.GetOwner(Entity)
	
	-- Check Owner.
	if (Owner) then
		local Friends = citrus.PlayerCookies.Get(Owner, "Entity Guard").Friends
		
		-- Check Friends.
		if (Friends[citrus.Player.GetUniqueID(Player)]) then return true end
	end
	
	-- Return False.
	return false
end

-- Player Spawned Object.
function PLUGIN.PlayerSpawnedObject(Player, Model, Entity)
	if (type(Model) == "string") then
		PLUGIN.GiveEntity(Player, Entity)
	else
		PLUGIN.GiveEntity(Player, Model)
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerSpawnedEffect", PLUGIN.PlayerSpawnedObject)
PLUGIN:HookAdd("PlayerSpawnedProp", PLUGIN.PlayerSpawnedObject)
PLUGIN:HookAdd("PlayerSpawnedNPC", PLUGIN.PlayerSpawnedObject)
PLUGIN:HookAdd("PlayerSpawnedVehicle", PLUGIN.PlayerSpawnedObject)
PLUGIN:HookAdd("PlayerSpawnedSENT", PLUGIN.PlayerSpawnedObject)
PLUGIN:HookAdd("PlayerSpawnedRagdoll", PLUGIN.PlayerSpawnedObject)

-- Init Post Entity.
function PLUGIN.InitPostEntity()
	local Entities = ents.GetAll()

	-- For Loop.
	for K, V in pairs(Entities) do PLUGIN.SetWorlds(V) end
end

-- Hook Add.
PLUGIN:HookAdd("InitPostEntity", PLUGIN.InitPostEntity)

-- Undo.
PLUGIN.Undo = {
	Create = undo.Create,
	AddEntity = undo.AddEntity,
	SetPlayer = undo.SetPlayer,
	Finish = undo.Finish
}

-- Create.
function undo.Create(Name)
 	PLUGIN.Undo.Entities = {}
	
	-- Create.
	PLUGIN.Undo.Create(Name)
end

-- Add Entity.
function undo.AddEntity(Entity)
	if (ValidEntity(Entity) and PLUGIN.Undo.Entities) then
		PLUGIN.Undo.Entities[#PLUGIN.Undo.Entities + 1] = Entity
	end
	
	-- Add Entity.
	PLUGIN.Undo.AddEntity(Entity)
end

-- Set Player.
function undo.SetPlayer(Player)
	if (ValidEntity(Player) and PLUGIN.Undo.Entities) then
		PLUGIN.Undo.Player = Player
	end
	
	-- Set Player.
	PLUGIN.Undo.SetPlayer(Player)
end

-- Finish.
function undo.Finish(Text)
	if (PLUGIN.Undo.Entities) then
		if (PLUGIN.Undo.Player) then
			if (ValidEntity(PLUGIN.Undo.Player)) then
				for K, V in pairs(PLUGIN.Undo.Entities) do
					PLUGIN.GiveEntity(PLUGIN.Undo.Player, V)
				end
			end
		end
	end
	
	-- Finish.
	PLUGIN.Undo.Finish(Text)
end

-- Player.
local Player = FindMetaTable("Player")

-- Add Count.
PLUGIN.AddCount = Player.AddCount

-- Add Count.
function Player:AddCount(Type, Entity)
	if (ValidEntity(Entity)) then PLUGIN.GiveEntity(self, Entity) end
	
	-- Add Count.
	PLUGIN.AddCount(self, Type, Entity)
end

-- Cleanup Add.
PLUGIN.CleanupAdd = cleanup.Add

-- Add.
function cleanup.Add(Player, Type, Entity)
	if (ValidEntity(Entity)) then PLUGIN.GiveEntity(Player, Entity) end
	
	-- Cleanup Add.
	PLUGIN.CleanupAdd(Player, Type, Entity)
end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")