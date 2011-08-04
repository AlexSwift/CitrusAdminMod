--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugin:New("Entity Guard")

-- On Load.
function PLUGIN:OnLoad()
	citrus.PlayerInformation.TypeAdd("Entity Guard")
	citrus.PlayerInformation.KeyAdd("Entity Guard", "Owner")
	citrus.PlayerInformation.KeyAdd("Entity Guard", "Class")
end

-- On Unload.
function PLUGIN:OnUnload()
	citrus.PlayerInformation.TypeRemove("Entity Guard")
	citrus.PlayerInformation.KeyRemove("Entity Guard", "Owner")
	citrus.PlayerInformation.KeyRemove("Entity Guard", "Class")
end

-- On Draw.
function PLUGIN.OnDraw()
	local Vehicle = LocalPlayer():InVehicle()
	
	-- Check Vehicle.
	if (!Vehicle) then
		local LocalPlayer = LocalPlayer()
		local Trace = citrus.Utilities.PlayerTrace(LocalPlayer)
		
		-- Check Valid Entity.
		if (ValidEntity(Trace.Entity)) then
			local IsWeapon = Trace.Entity:IsWeapon()
			local IsPlayer = Trace.Entity:IsPlayer()
			local IsWorld = Trace.Entity:IsWorld()
			
			-- Check Is Weapon.
			if (!IsWeapon and !IsPlayer and !IsWorld) then
				local Owner = citrus.PlayerInformation.Get(LocalPlayer, "Entity Guard", "Owner")
				
				-- Check Owner.
				if (Owner) then
					local BackgroundColor = citrus.Themes.GetColor("Background")
					local CornerSize = citrus.Themes.GetSize("Corner")
					local TitleColor = citrus.Themes.GetColor("Title")
					local TextColor = citrus.Themes.GetColor("Text")
					
					-- Set Font.
					surface.SetFont("citrus_MainText")
					
					-- Owner.
					if (Owner != "Abandoned" and Owner != "Unowned") then Owner = "Owner: "..Owner end
					
					-- Class.
					local Class = citrus.PlayerInformation.Get(LocalPlayer, "Entity Guard", "Class")
					
					-- X.
					local X = ScrW() / 2
					local Y = ScrH()
					
					-- Rounded Text Box.
					citrus.Draw.RoundedTextBox(Owner, "citrus_MainText", TextColor, X, Y, CornerSize, BackgroundColor, Class, TitleColor, true, nil, function(X, Y, Width, Height)
						return X, Y - Height - 8
					end)
				end
			end
		end
	end
end

-- Usermessage Hook.
PLUGIN:UsermessageHook("Remove Entities", function(Message)
	local Entities = ents.GetAll()
	
	-- For Loop.
	for K, V in pairs(Entities) do
		if (V:GetClass() == "client_ragdoll" or V:GetClass() == "class C_PhysPropClientside") then
			V:Remove()
		end
	end
	
	-- Con Command.
	LocalPlayer():ConCommand("r_clearcecals\n")
end)

-- Usermessage Hook.
PLUGIN:UsermessageHook("Fix Color", function(Message)
	local Entity = Message:ReadEntity()
	
	-- Check Valid Entity.
	if (ValidEntity(Entity)) then
		local R = Message:ReadShort()
		local G = Message:ReadShort()
		local B = Message:ReadShort()
		local A = Message:ReadShort()
		
		-- Set Color.
		Entity:SetColor(R, G, B, A)
	end
end)

-- Usermessage Hook.
PLUGIN:UsermessageHook("Fix Material", function(Message)
	local Entity = Message:ReadEntity()
	
	-- Check Valid Entity.
	if (ValidEntity(Entity)) then
		local Material = Message:ReadString()
		
		-- Set Material.
		Entity:SetMaterial(Material)
	end
end)