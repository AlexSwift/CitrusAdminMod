--[[
Name: "sv_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Translate")

-- Game Support.
PLUGIN.Settings.GameSupport = false
PLUGIN.Settings.Description = "Entities can be stacked by visual translation"
PLUGIN.Settings.Gamemode = {"Sandbox", true}
PLUGIN.Settings.Author = "Conna"

-- Include.
include("sh_plugin.lua")

-- On Player Set Variables.
function PLUGIN.OnPlayerSetVariables(Player)
	citrus.PlayerCookies.New(Player, "Translate", {})
end

-- On Player Unload.
function PLUGIN:OnPlayerUnload(Player) PLUGIN.FinishTranslating(Player) end

-- Start Translating.
function PLUGIN.StartTranslating(Player, Entity, Weld)
	local Translate = citrus.PlayerCookies.Get(Player, "Translate")
	
	-- Active.
	Translate.Active = true
	Translate.PreventMove = true
	Translate.Entities = Translate.Entities or {}
	
	-- Table.
	local Table = {}
	
	-- Weld.
	Table.Weld = Weld
	Table.Entity = Entity
	
	-- Create Ghosts.
	PLUGIN.CreateGhosts(Player, Entity)
	
	-- Entities.
	Translate.Entities[#Translate.Entities + 1] = Table
end

-- Finish Translating.
function PLUGIN.FinishTranslating(Player, Temporary, Entity)
	local Translate = citrus.PlayerCookies.Get(Player, "Translate")
	
	-- Check Entity.
	if (Entity) then
		for K, V in pairs(Translate.Entities) do
			if (V.Entity == Entity) then
				PLUGIN.RemoveGhosts(Player, V.Entity)
				
				-- K.
				Translate.Entities[K] = nil
				
				-- Check Count.
				if (table.Count(Translate.Entities) == 0) then
					PLUGIN.FinishTranslating(Player)
				end
				
				-- Return.
				return
			end
		end
	else
		PLUGIN.RemoveGhosts(Player)
		
		-- Entities.
		Translate.Active = nil
		Translate.Entities = nil
		
		-- Check Temporary.
		if (!Temporary) then Translate.PreventMove = nil end
	end
end

-- Remove Ghosts.
function PLUGIN.RemoveGhosts(Player, Entity)
	local Translate = citrus.PlayerCookies.Get(Player, "Translate")
	
	-- Check Entity.
	if (!Entity) then
		PLUGIN:UsermessageCall("Remove All Ghosts", Player)
	else
		if (Translate.Active) then
			for K, V in pairs(Translate.Entities) do
				if (V.Entity == Entity) then
					PLUGIN:UsermessageCall("Remove Ghosts", Player, function() umsg.Entity(V.Entity) end)
				end
			end
		end
	end
end

-- Create Ghosts.
function PLUGIN.CreateGhosts(Player, Entity)
	PLUGIN:UsermessageCall("Create Ghosts", Player, function() umsg.Entity(Entity) end)
end

-- Move.
function PLUGIN.Move(Player, MoveData)
	if (citrus.PlayerVariables.Exists(Player)) then
		local Translate = citrus.PlayerCookies.Get(Player, "Translate")
		local PreventMove = Translate.PreventMove
		
		-- Check Prevent Move.
		if (PreventMove) then
			local KeyDown = Player:KeyDown(IN_SPEED)
			
			-- Check Key Down.
			if (KeyDown) then return true end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("Move", PLUGIN.Move)

-- On Player Second.
function PLUGIN.OnPlayerSecond(Player)
	local Translate = citrus.PlayerCookies.Get(Player, "Translate")
	
	-- Set.
	citrus.PlayerInformation.Set(Player, "Translate", "Active", (Translate.PreventMove == true))
	
	-- Check Active.
	if (Translate.Active) then
		local Valid = false
		
		-- For Loop.
		for K, V in pairs(Translate.Entities) do
			if (ValidEntity(V.Entity)) then
				Valid = true
				
				-- Break.
				break
			end
		end
		
		-- Check Valid.
		if (!Valid) then
			PLUGIN.FinishTranslating(Player)
		end
	end
end

-- Key Press.
function PLUGIN.KeyPress(Player, Key)
	if (citrus.PlayerVariables.Exists(Player)) then
		local Translate = citrus.PlayerCookies.Get(Player, "Translate")
		
		-- Check Active.
		if (Translate.Active) then
			local KeyDown = Player:KeyDown(IN_SPEED)
			
			-- Check Key Down.
			if (KeyDown) then
				if (Key == IN_USE) then
					PLUGIN.FinishTranslating(Player)
				elseif (Key == IN_FORWARD or Key == IN_BACK or Key == IN_MOVELEFT or Key == IN_MOVERIGHT or Key == IN_JUMP or Key == IN_DUCK) then
					local Duplicates = {}
					
					-- For Loop.
					for K, V in pairs(Translate.Entities) do
						if (ValidEntity(V.Entity)) then
							local Duplicate = citrus.Utilities.DuplicateEntity(Player, V.Entity)
							
							-- Check Duplicate.
							if (!Duplicate) then PLUGIN.FinishTranslating(Player) return end
							
							-- Translate Entity.
							PLUGIN.TranslateEntity(V.Entity, Duplicate, Key)
							
							-- Is In World.
							local IsInWorld = Duplicate:IsInWorld()
							
							-- Check Is In World.
							if (!IsInWorld) then Duplicate:Remove() end
							
							-- Check Valid Entity.
							if (ValidEntity(Duplicate)) then
								local Constraint = nil
								
								-- Check Weld.
								if (V.Weld) then
									Constraint = constraint.Weld(V.Entity, Duplicate, 0, 0, 0, false)
								end
								
								-- Table.
								local Table = {}
								
								-- Weld.
								Table.Weld = V.Weld
								Table.Constraint = Constraint
								Table.Entity = Duplicate
								
								-- Duplicates.
								Duplicates[#Duplicates + 1] = Table
							end
						end
					end
					
					-- Finish Translating.
					PLUGIN.FinishTranslating(Player, true)
					
					-- Create.
					undo.Create("Translation")
					
					-- For Loop.
					for K, V in pairs(Duplicates) do
						if (ValidEntity(V.Constraint)) then
							Player:AddCleanup("constraints", V.Constraint)
							
							-- Add Entity.
							undo.AddEntity(V.Constraint)
						end
						
						-- Check Valid Entity.
						if (ValidEntity(V.Entity)) then
							Player:AddCleanup("props", V.Entity)
							
							-- Add Entity.
							undo.AddEntity(V.Entity)
						end
					end
					
					-- Set Player.
					undo.SetPlayer(Player)
					undo.Finish()
					
					-- Simple.
					timer.Simple(0.5, function()
						for K, V in pairs(Duplicates) do
							if (ValidEntity(V.Entity)) then
								PLUGIN.StartTranslating(Player, V.Entity, V.Weld)
							end
						end
						
						-- Check Active.
						if (!Translate.Active) then
							PLUGIN.FinishTranslating(Player)
						end
					end)
				end
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("KeyPress", PLUGIN.KeyPress)

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/commands/", "sv_", ".lua")