--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Translate")

-- Entities.
PLUGIN.Entities = {}

-- Include.
include("sh_plugin.lua")

-- Add.
language.Add("Undone_Translation", "Undone Translation")

-- Usermessage Hook.
PLUGIN:UsermessageHook("Remove Ghosts", function(Message)
	local Entity = Message:ReadEntity()
	
	-- Check Valid Entity.
	if (ValidEntity(Entity)) then
		for K, V in pairs(PLUGIN.Entities) do
			if (V.Entity == Entity) then
				for K2, V2 in pairs(V.Ghosts) do
					if (ValidEntity(V2)) then V2:Remove() end
				end
				
				-- K.
				PLUGIN.Entities[K] = nil
			end
		end
	end
end)

-- Usermessage Hook.
PLUGIN:UsermessageHook("Remove All Ghosts", function(Message)
	for K, V in pairs(PLUGIN.Entities) do
		for K2, V2 in pairs(V.Ghosts) do
			if (ValidEntity(V2)) then V2:Remove() end
		end
		
		-- K.
		PLUGIN.Entities[K] = nil
	end
end)

-- Usermessage Hook.
PLUGIN:UsermessageHook("Create Ghosts", function(Message)
	local Entity = Message:ReadEntity()
	
	-- Check Valid Entity.
	if (ValidEntity(Entity)) then
		for K, V in pairs(PLUGIN.Entities) do
			if (V.Entity == Entity) then return end
		end
		
		-- Angles.
		local Angles = Entity:GetAngles()
		local Model = Entity:GetModel()
		
		-- Table.
		local Table = {}
		
		-- Entity.
		Table.Entity = Entity
		Table.Ghosts = {}
		
		-- For Loop.
		for I = 1, 6 do
			Table.Ghosts[I] = ents.Create("prop_physics")
			
			-- Set Model.
			Table.Ghosts[I]:SetModel(Model)
			Table.Ghosts[I]:Spawn()
			
			-- Set Solid.
			Table.Ghosts[I]:SetSolid(SOLID_VPHYSICS)
			Table.Ghosts[I]:SetMaterial("models/debug/debugwhite")
			Table.Ghosts[I]:SetMoveType(MOVETYPE_NONE)
			Table.Ghosts[I]:SetNotSolid(true)
			Table.Ghosts[I]:SetRenderMode(RENDERMODE_TRANSALPHA)
			
			-- Key.
			local Key = false
			
			-- Check I.
			if (I == 1) then
				Table.Ghosts[I]:SetColor(255, 0, 0, 200) Key = IN_FORWARD
			elseif (I == 2) then
				Table.Ghosts[I]:SetColor(255, 125, 255, 200) Key = IN_BACK
			elseif (I == 3) then
				Table.Ghosts[I]:SetColor(0, 255, 0, 200) Key = IN_MOVERIGHT
			elseif (I == 4) then
				Table.Ghosts[I]:SetColor(255, 255, 0, 200) Key = IN_MOVELEFT
			elseif (I == 5) then
				Table.Ghosts[I]:SetColor(0, 0, 255, 200) Key = IN_JUMP
			elseif (I == 6) then
				Table.Ghosts[I]:SetColor(100, 50, 150, 200) Key = IN_DUCK
			end
			
			-- Translate Entity.
			PLUGIN.TranslateEntity(Entity, Table.Ghosts[I], Key)
			
			-- Set Angles		
			Table.Ghosts[I]:SetAngles(Angles)
			Table.Ghosts[I]:SetParent(Entity)
			Table.Ghosts[I]:SetModelScale(Vector(0.9, 0.9, 0.9))
		end
		
		-- For Loop.
		for K, V in pairs(Table.Ghosts) do
			Entity:CallOnRemove(tostring(V), function()
				for K2, V2 in pairs(PLUGIN.Entities) do
					if (V2.Entity == Entity) then
						if (ValidEntity(V2.Ghosts[K])) then
							V2.Ghosts[K]:Remove()
							V2.Ghosts[K] = nil
							
							-- Check Count.
							if (table.Count(V2.Ghosts) == 0) then
								PLUGIN.Entities[K2] = nil
							end
							
							-- Break.
							break
						end
					end
				end
			end)
		end
		
		-- Entities.
		PLUGIN.Entities[#PLUGIN.Entities + 1] = Table
	end
end)

-- On Load.
function PLUGIN:OnLoad()
	citrus.PlayerInformation.TypeAdd("Translate")
	citrus.PlayerInformation.KeyAdd("Translate", "Active")
end

-- On Unload.
function PLUGIN:OnUnload()
	citrus.PlayerInformation.TypeRemove("Translate")
	citrus.PlayerInformation.KeyRemove("Translate", "Active")
end

-- On Draw.
function PLUGIN.OnDraw()
	local Active = citrus.PlayerInformation.Get(LocalPlayer(), "Translate", "Active")
	
	-- Check Active.
	if (Active) then
		local BackgroundColor = citrus.Themes.GetColor("Background")
		local CornerSize = citrus.Themes.GetSize("Corner")
		local TitleColor = citrus.Themes.GetColor("Title")
		local TextColor = citrus.Themes.GetColor("Text")
		
		-- X, Y.
		local X, Y = 8, 8
		
		-- Table.
		local Table = {
			"Red: Sprint + Forward",
			"Pink: Sprint + Backward",
			"Green: Sprint + Right",
			"Yellow: Sprint + Left",
			"Blue: Sprint + Jump",
			"Purple: Sprint + Duck",
			"Exit: Sprint + Use"
		}
		
		-- Announcements.
		local Announcements = citrus.Plugins.Get("Announcements")
		
		-- Check Announcements.
		if (Announcements) then
			local IsLoaded = Announcements:IsLoaded()
			
			-- Check Is Loaded.
			if (IsLoaded) then
				if (Announcements.Announcement) then
					Y = 48
				end
			end
		end
		
		-- Rounded Text Box.
		citrus.Draw.RoundedTextBox(Table, "citrus_MainText", TextColor, X, Y, CornerSize, BackgroundColor, "Translate", TitleColor)
	end
end