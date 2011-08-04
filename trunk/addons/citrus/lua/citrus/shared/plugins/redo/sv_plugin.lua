--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Redo")

-- Description.
PLUGIN.Settings.Description = "Players can redo entities that they have undone"
PLUGIN.Settings.Gamemode = {"Sandbox", true}
PLUGIN.Settings.Author = "Conna"

-- Create ConVar.
CreateConVar("sv_citrus_redo_limit", 25, {FCVAR_NOTIFY, FCVAR_ARCHIVE})

-- Undos.
PLUGIN.Redos = {}

-- Get Constraint.
function PLUGIN.GetConstraint(Entity)
	local Constraint = {}
	
	-- Table.
	local Table = Entity:GetTable()
	
	-- Merge.
	table.Merge(Constraint, Table)

	-- Constraint.
	Constraint.Constraint = Entity
	Constraint.Entity = {} 
	
	-- For Loop.
	for I = 1, 6 do 
		if (Constraint["Ent"..I] and (Constraint["Ent"..I]:IsWorld() or ValidEntity(Constraint["Ent"..I]))) then 
			Constraint.Entity[I] = {} 
			Constraint.Entity[I].Index = Constraint["Ent"..I]:EntIndex() 
			Constraint.Entity[I].Entity	= Constraint["Ent"..I] 
			Constraint.Entity[I].Bone = Constraint["Bone"..I] 
			Constraint.Entity[I].LPos = Constraint["LPos"..I] 
			Constraint.Entity[I].WPos = Constraint["WPos"..I] 
			Constraint.Entity[I].Length = Constraint["Length"..I] 
			Constraint.Entity[I].World	= Constraint["Ent"..I]:IsWorld() 
		end 
	end
	
	-- Return Constraint.
	return Constraint
end

-- Create Constraint.
function PLUGIN.CreateConstraint(Table, Cache)
	local Factory = duplicator.ConstraintType[Table.Type]
	
	-- Check Factory.
	if (!Factory) then return end 

	-- Arguments.
	local Arguments = {}
	
	-- For Loop.
	for K, V in pairs(Factory.Args) do 
		local Value = Table[V] 
		
		-- For Loop.
		for I = 1, 6 do  
			if (Table.Entity[I]) then 
				if (V == "Ent"..I) then	 
					local Success = false
					
					-- Check Index.
					if (Cache[Table.Entity[I].Index]) then
						Value = Cache[Table.Entity[I].Index]
						
						-- Success.
						Success = true
					end
					
					-- Check Success.
					if (!Success) then
						Value = Entity(Table.Entity[I].Index)
						
						-- Check World.
						if (Table.Entity[I].World) then Value = GetWorldEntity() end 
					end
				end
				
				-- Check V.
				if (V == "Bone"..I) then Value = Table.Entity[I].Bone end 
				if (V == "LPos"..I) then Value = Table.Entity[I].LPos end 
				if (V == "WPos"..I) then Value = Table.Entity[I].WPos end 
				if (V == "Length"..I) then Value = Table.Entity[I].Length end 
			end 
		end 
		
		-- Check Value.
		if (Value == nil) then Value = false end 
		
		-- Insert.
		table.insert(Arguments, Value) 
	end 
	
	-- Constraint.
	local Constraint = Factory.Func(unpack(Arguments)) 
	
	-- Return Constraint.
	return Constraint
end

-- Is Constraint.
function PLUGIN.IsConstraint(Entity)
	if (Entity.Type and duplicator.ConstraintType[Entity.Type]) then
		return true
	else
		return false
	end
end

-- Redo.
function PLUGIN.Redo(Player, Index)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Redo.
	local Redo = PLUGIN.Redos[UniqueID][Index]
	
	-- Check Redo.
	if (Redo) then
		local Entities = duplicator.Paste(Player, Redo.Entities, {})
		local Constraints = {}
		local Cache = {}
		local All = ents.GetAll()
		
		-- For Loop.
		for K, V in pairs(Entities) do V.Redo = {} V.Redo.Index = K end
		for K, V in pairs(All) do
			if (V.Redo) then Cache[V.Redo.Index] = V end
		end
		
		-- For Loop.
		for K, V in pairs(Redo.Constraints) do
			local Constraint = PLUGIN.CreateConstraint(V, Cache)
			
			-- Insert.
			table.insert(Constraints, Constraint)
		end
		
		-- Create.
		undo.Create(Redo.Name)
		
		-- For Loop.
		for K, V in pairs(Entities) do undo.AddEntity(V) end
		for K, V in pairs(Constraints) do undo.AddEntity(V) end
		
		-- Set Player.
		undo.SetPlayer(Player)
		undo.Finish()
		
		-- Index.
		PLUGIN.Redos[UniqueID][Index] = nil
		
		-- Notify.
		citrus.Player.Notify(Player, "Redone "..Redo.Name, 2)
		
		-- Return True.
		return true
	end
	
	-- Return false
	return false
end

-- Copy Constraints.
function PLUGIN.CopyConstraints(Entity, Entities, Constraints)
	if (constraint.HasConstraints(Entity)) then
		for K, V in pairs(Entity.Constraints) do
			PLUGIN.CopyEntity(V, Entities, Constraints)
		end
	end
end

-- Copy Entity.
function PLUGIN.CopyEntity(Entity, Entities, Constraints)
	if (PLUGIN.IsConstraint(Entity)) then
		for K, V in pairs(Constraints) do
			if (V.Constraint == Entity) then return end
		end
		
		-- Constraint.
		local Constraint = PLUGIN.GetConstraint(Entity)
		
		-- Insert.
		table.insert(Constraints, Constraint)
		
		-- For Loop.
		for K, V in pairs(Constraint.Entity) do
			if (ValidEntity(V.Entity)) then
				PLUGIN.CopyConstraints(V.Entity, Entities, Constraints)
			end
		end
	else
		local Index = Entity:EntIndex()
		
		-- Check Index.
		if (!Entities[Index]) then
			local Copy = duplicator.CopyEntTable(Entity)
			
			-- Check Copy.
			if (Copy) then
				Copy.Index = Index
				
				-- Index.
				Entities[Index] = Copy
				
				-- Copy Constraints.
				PLUGIN.CopyConstraints(Entity, Entities, Constraints)
			end
		end
	end
end

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	local UniqueID = citrus.Player.GetUniqueID(Player)
	
	-- Unique ID.
	PLUGIN.Redos[UniqueID] = PLUGIN.Redos[UniqueID] or {}
end

-- DO_UNDO.
local DO_UNDO = undo.Do_Undo

-- On Load.
function PLUGIN:OnLoad()
	undo.Do_Undo = PLUGIN.Do_Undo
end

-- On Unload.
function PLUGIN:OnUnload()
	undo.Do_Undo = DO_UNDO
end

-- Do_Undo.
function PLUGIN.Do_Undo(Undo)
	if (!Undo) then return false end
	
	-- Redo.
	local Redo = {Entities = {}, Constraints = {}, Name = Undo.Name, Player = Undo.Owner, Count = 0}
	
	-- Check Entities.
	if (Undo.Entities) then
		if (#Undo.Entities <= GetConVarNumber("sv_citrus_redo_limit")) then
			for K, V in pairs(Undo.Entities) do
				if (ValidEntity(V)) then
					PLUGIN.CopyEntity(V, Redo.Entities, Redo.Constraints)
					
					-- Count.
					Redo.Count = Redo.Count + 1
				end
			end
		end
	end
	
	-- Check Count.
	if (Redo.Count > 0) then
		local UniqueID = citrus.Player.GetUniqueID(Redo.Player)
		
		-- Unique ID.
		PLUGIN.Redos[UniqueID][#PLUGIN.Redos[UniqueID] + 1] = Redo
	end
	
	-- Return DO_UNDO.
	return DO_UNDO(Undo)
end

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")